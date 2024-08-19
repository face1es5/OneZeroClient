//
//  Uploader.swift
//  OneZero
//
//  Created by Fish on 15/8/2024.
//

import Foundation

/// Singleton for uploading videos. Server's api is holding internal(UserDefaults).
///
/// - upload(for video: VideoItem, to path: String): read data and upload to server asynchronously.
/// - upload(from localPath: String, to serverPath: String): wrapper for upload(for video, to path), which localPath is a string.
/// - uploadVideos(_ videos: [String], to serverPath: String): wrapper for upload(from localPath, to serverPath) that uploads a series of videos.
class Uploader {
    static let shared = Uploader()
    private var baseURL = UserDefaults.standard.string(forKey: "api")!
    
    private init() {}
    
    /**
     Asynchronously upload **video** to **path**.
     */
    func upload(for video: VideoItem, to path: String) async {
        let url = "\(baseURL)/\(path)"
        await MainActor.run {
            video.uploading = true
        }
        
        print("Read Data of \(video.name)...")
        guard
            let data = try? Data(contentsOf: video.url)
        else {
            print("Read \(video.name) failed. Upload terminated.")
            return
        }
        print("Ready to post \(video.name) on \(url)")
        await APIService(to: url).postVideo(for: data, name: video.name) { result in
            switch result {
            case let .success(message):
                print("Upload \(video.name) success: \(message).")
            case let .failure(message):
                print("Upload \(video.name) failed: \(message)")
            }
        }
        
        await MainActor.run {
            video.uploading = false
        }
    }

    /**
     Upload video **from** localPath and **to** serverPath.
     */
    func upload(from localPath: String, to serverPath: String) async {
        async let video = VideoItem(from: localPath)
        await upload(for: video, to: serverPath)
    }
    
    /**
     Upload videos **to** serverPath in parallel.
     */
    func uploadVideos(_ videos: [String], to serverPath: String) async {
        for path in videos {
            Task {
                await Uploader.shared.upload(from: path, to: serverPath)
            }
        }
    }
}

/// Class that holds a group of related tasks(like uploading videos from a range selection).
class UploadTaskGroup: Identifiable, ObservableObject {
    let id = UUID().uuidString
    let name: String
    @Published var videos: [VideoItem]
    let destination: String
    @Published var isPaused = false
    @Published var isStarted = false
    @Published var isFinished = false
    @Published var isHalted = false
    @Published var finishedNum: Double = 0
    var totalNum: Double {
        Double(videos.count)
    }
    private let startingMutex = NSLock()
    
    init(videos: [VideoItem], destination: String, isPaused: Bool = false) {
        self.videos = videos
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
                for video in videos {
                    taskGroup.addTask {
                        await Uploader.shared.upload(for: video, to: self.destination)
                        await MainActor.run {
                            self.finishedNum += 1
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
    private let taskQueue = DispatchQueue(label: "com.OneZero.uploadmanager.taskqueue", qos: .background)
    
    // singleton, and start processing
    private init() {
        processing()
    }
    
    func uploadRequest(for video: VideoItem, to path: String) {
        addTaskGroup(UploadTaskGroup(videos: [video], destination: path))
    }
    func uploadRequest(for videos: [VideoItem], to path: String) {
        addTaskGroup(UploadTaskGroup(videos: videos, destination: path))
    }
    func uploadRequest(for videos: Set<VideoItem>, to path: String) {
        uploadRequest(for: Array(videos), to: path)
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
        taskQueue.async { [weak self] in
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
