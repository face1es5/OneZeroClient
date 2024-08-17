//
//  VideosViewModel.swift
//  OneZero
//
//  Created by Fish on 14/8/2024.
//

import Foundation

class VideosViewModel: ObservableObject {
    @Published var videos: [VideoItem] = []

    func load(from urls: [URL]) {
        videos = urls.map { VideoItem(from: $0) }
    }

    func load(from urls: [String]) {
        videos = urls.map { VideoItem(from: $0) }
    }

    func count() -> Int { return videos.count }
    func clear() { videos = [] }
}
