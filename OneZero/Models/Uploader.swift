//
//  Uploader.swift
//  OneZero
//
//  Created by Fish on 15/8/2024.
//

import Foundation

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
                await Uploader.shared.upload(from:path, to: serverPath)
            }
        }
    }
}
