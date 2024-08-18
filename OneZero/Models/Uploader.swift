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
    
    /**
     Asynchronously upload **video** to **path**.
     */
    func upload(for video: VideoItem, to path: String) async {
        let url = "\(baseURL)/\(path)"
        await MainActor.run {
            video.uploading = true
        }
        defer { Task { @MainActor in video.uploading = false } }
        
        print("Read Data of \(video.name)...")
//        let data = try Data(contentsOf: video.url)
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
    let description: String
    @Published var videos: [VideoItem]
    let destination: String
    @Published var isPaused = false
    @Published var isStarted = false
    @Published var isFinished = false
    @Published var isHalted = false
    
    init(videos: [VideoItem], destination: String, isPaused: Bool = false) {
        self.videos = videos
        self.destination = destination
        self.isPaused = isPaused
        self.name = "\(videos.count) to upload to \(destination)"
        self.description = id
    }
    
    func pause() {
        isPaused = true
    }
    
    func resume() {
        isPaused = false
    }
    
    func pseudoUpload(video: VideoItem) async {
        do {
            try await Task.sleep(for: .seconds(3))
            try await Task.sleep(for: .seconds(3))
            print("Upload \(video.name) success.")
        } catch {
            print("Upload \(video.name) failed.")
        }
    }
    
    // start uploading asynchronously
    func start() async {
        await MainActor.run {
            isStarted = true
        }
        for video in videos {
            await pseudoUpload(video: video)
        }
        // all upload tasks done, set finished.
    }
    
}

/// Manager for upload-groups, which means it holds a collection of UploadTasksGroup.
///
/// - Traditionally, **processing procedure** should **run in a single thread**, any
class UploadManager: ObservableObject {
    static let shared = UploadManager()
    @Published var taskGroups: [UploadTaskGroup] = []
    private let mutex = NSLock()
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
        mutex.lock()
        taskGroups.append(group)
        mutex.unlock()
        // wake up
        condition.signal()
    }
    
    func processing() {
        taskQueue.async { [weak self] in
            guard let self = self else { return }
            while true {    // process tasks.
                mutex.lock()    // acquire lock to prevent break procedure of addTaskGroup
                while taskGroups.isEmpty {
                    /**
                     If no task available, suspend processing thread until a signal that indicates
                     whether a new task is added or a existed task is requested to execute.
                     */
                    mutex.unlock()
                    condition.wait()
                    mutex.lock()
                }
                // now we have a task to run, take the first task group
                guard let group = taskGroups.first else {   // task is not available, release mutex and continue to wait next task.
                    mutex.unlock()
                    continue
                }
                // here we should check status of group ( started? paused? finished? halted?)
                if !group.isStarted {
                    Task {
                        await group.start()
                    }
                } else if group.isFinished {
                    taskGroups.removeFirst()
                }   // TODO: else if paused/halted
                mutex.unlock()
            }
        }
    }
}
