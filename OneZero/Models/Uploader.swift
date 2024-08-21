//
//  Uploader.swift
//  OneZero
//
//  Created by Fish on 15/8/2024.
//

import Foundation

/// Singleton for uploading media. Server's api is holding internal(UserDefaults).
///
/// - upload(for media: MediaItem, to path: String): read data and upload to server asynchronously.
/// - upload(from localPath: String, to serverPath: String): wrapper for upload(for media, to path), which localPath is a string.
/// - uploadSomeMedia(_ medias: [String], to serverPath: String): wrapper for upload(from localPath, to serverPath) that uploads a series of media.
class Uploader {
    static let shared = Uploader()
    private var baseURL = UserDefaults.standard.string(forKey: "api") ?? "what://"
    
    private init() {}
    
    /**
     Asynchronously upload **media** to **path**.
     Return true if success, false if failed.
     */
    func upload(for media: MediaItem, to path: String) async -> Bool {
        let url = "\(baseURL)/\(path)"
        await MainActor.run {
            media.uploading = true
        }
        
        do { try await Task.sleep(for: .seconds(3)) } catch {}
        
        defer {
            Task { @MainActor in media.uploading = false }
        }
        
        print("Read Data of \(media.name)...")
        guard
            let data = try? Data(contentsOf: media.url)
        else {
            print("Read \(media.name) failed. Upload terminated.")
            return false
        }
        print("Ready to post \(media.name) on \(url)")
        let result = await APIService(to: url).postMedia(for: data, name: media.name, extension: media.url.pathExtension)
        switch result {
        case let .success(message):
            await MainActor.run { media.failedToUploading = false }
            print("Upload \(media.name) success: \(message).")
            return true
        case let .failure(error):
            print("Upload \(media.name) failed: \(error)")
            await MainActor.run {
                if let apiError = error as? APIError {
                    media.errorHint = apiError.errorDescription
                } else {
                    media.errorHint = error.localizedDescription
                }
                media.failedToUploading = true
            }
            return false
        }
    }

    /**
     Upload media **from** localPath and **to** serverPath.
     */
    func upload(from localPath: String, to serverPath: String) async -> Bool {
        async let media = MediaItem(from: localPath)
        return await upload(for: media, to: serverPath)
    }
    
    /**
     Upload media in paths **to** serverPath in parallel.
     */
    func uploadSomeMedia(_ paths: [String], to serverPath: String) async {
        for path in paths {
            Task {
                await Uploader.shared.upload(from: path, to: serverPath)
            }
        }
    }
}

/// Class that holds a group of related tasks(like uploading some media from a range selection).
class UploadTaskGroup: Identifiable, ObservableObject {
    let id = UUID().uuidString
    let name: String
    @Published var mediaItems: [MediaItem]
    let destination: String
    @Published var isPaused = false
    @Published var isStarted = false
    @Published var isFinished = false
    @Published var isHalted = false
    @Published var finishedNum: Double = 0
    @Published var failedNum: Int = 0
    var totalNum: Double {
        Double(mediaItems.count)
    }
    private let startingMutex = NSLock()
    
    init(mediaItems: [MediaItem], destination: String, isPaused: Bool = false) {
        self.mediaItems = mediaItems
        self.destination = destination
        self.isPaused = isPaused
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.name = "\(dateFormatter.string(from: Date()))"
    }
    
    func pause() {
        isPaused = true
    }
    
    func resume() {
        isPaused = false
    }
    
    // start uploading asynchronously
    func start() {
        print("Upload group \(name)")
        isStarted = true
        Task {
            await withTaskGroup(of: Void.self) { taskGroup in
                for media in mediaItems {
                    taskGroup.addTask {
                        let success = await Uploader.shared.upload(for: media, to: self.destination)
                        DispatchQueue.main.async {
                            self.finishedNum += 1
                            if !success { self.failedNum += 1 }
                        }
                    }
                }
            }
            // all upload tasks done, set finished.
            await MainActor.run {
                isFinished = true
            }
        }
    }
}

/// Manager for upload-groups, which means it holds a collection of UploadTasksGroup.
///
/// - Traditionally, **processing procedure** should **run in a single thread**, so hide this function and start it in private constructor.
class UploadManager: ObservableObject {
    static let shared = UploadManager()
    @Published var taskGroups: [UploadTaskGroup] = []
    private let condition = NSCondition()   // condition to wake up processing thread
    private let uploadTaskQueue = DispatchQueue(label: "com.OneZero.uploadmanager.taskqueue", qos: .background)
    
    // singleton, and start processing
    private init() {
        processing()
    }
    
    func uploadRequest(for mediaItem: MediaItem, to path: String) {
        addTaskGroup(UploadTaskGroup(mediaItems: [mediaItem], destination: path))
    }
    func uploadRequest(for mediaItems: [MediaItem], to path: String) {
        addTaskGroup(UploadTaskGroup(mediaItems: mediaItems, destination: path))
    }
    func uploadRequest(for mediaItems: Set<MediaItem>, to path: String) {
        uploadRequest(for: Array(mediaItems), to: path)
    }
    
    func addTaskGroup(_ group: UploadTaskGroup) {
        // lock when new group append
        condition.lock()
        taskGroups.append(group)
        condition.unlock()
        // wake up
        condition.signal()
    }
    
    func removeTaskGroup(_ group: UploadTaskGroup) {
        // lock
        condition.lock()
        if let idx = taskGroups.firstIndex(where: { $0.id == group.id }) {
            taskGroups.remove(at: idx)
        }
        condition.unlock()
    }
    
    /// Take first upload-group that not yet started and start it.
    ///
    /// - TODO: Fix multi-uploading, check synchronous state pass between taskgroup and manager. -> **Fixed**, this problem caused by running upload operation in task, which means update isStarted inside taskgroup's start func is asynchrously although change it in Main Thread, **i.e: Race condition will occur when uploading operation**(i mean total function, which means before making isStarted=true) **is hanged in background and processing thread re-fetch the first taskgroup**(as i just fetch the first group in queue, but even filter to fetch first group which isStarted=false is useless too, **because we don't make group's isStarted=true immediately after creating the group that start function of this group maybe hanged on background, so the timing of making isStarted=true is uncertain, and if it changed after re-fetching, same task-group will be started multi-times**.)
    /// - TODO: handle pausing/halting
    private func processing() {
        uploadTaskQueue.async { [weak self] in
            guard let self = self else { return }
            while true {    // process tasks.
                condition.lock()    // acquire lock to continue.
                while taskGroups.isEmpty {
                    /**
                     If no task available, suspend processing thread until a signal that indicates
                     whether a new task is added or a existed task is requested to execute.
                     */
                    condition.wait()
                }
                // now we have a task to run, take the first task group
                guard let group = taskGroups.first(where: {
                    $0.isStarted == false
                }) else {   // task is not available, release mutex and continue to wait next task.
                    condition.unlock()
                    continue
                }
                // here we should check status of group ( started? paused? finished? halted?)
                print("Start group \(group.name)")
                group.start()
                // TODO: handle pasuing/halting
                condition.unlock()
            }
        }
    }
}
