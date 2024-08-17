//
//  VideosViewModel.swift
//  OneZero
//
//  Created by Fish on 14/8/2024.
//

import Foundation

class VideosViewModel: ObservableObject {
    @Published var videos: [VideoItem] = [] {
        didSet {
            Task { await doFilter() }
        }
    }
    @Published var searchString: String = "" {
        didSet {
            Task { await doFilter() }
        }
    }
    @Published var filteredMedia: [VideoItem] = []
    
    private func filterMedia() async -> [VideoItem] {
        guard !searchString.isEmpty else { return videos }
        return videos.filter {
            $0.name.lowercased().contains(searchString.lowercased())
        }
    }
    
    private func doFilter() async {
        Task {
            let res = await filterMedia()
            DispatchQueue.main.async {
                self.filteredMedia = res
            }
        }
    }
    
    func load(from urls: [URL]) {
        videos = urls.map { VideoItem(from: $0) }
    }

    func load(from urls: [String]) {
        videos = urls.map { VideoItem(from: $0) }
    }

    func count() -> Int { return videos.count }
    func clear() { videos = [] }
}
