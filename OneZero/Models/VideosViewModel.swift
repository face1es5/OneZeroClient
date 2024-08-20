//
//  VideosViewModel.swift
//  OneZero
//
//  Created by Fish on 14/8/2024.
//

import Foundation

/// A View Model holds a collection of media, **also it has a internal selectionModel reference**.
///
/// **Any modification on internal items will clear selection.**
class VideosViewModel: ObservableObject {
    private var selectionModel: SelectionModel<VideoItem>?
    @Published var videos: [VideoItem] = [] {
        didSet {
            Task { await doFilter() }
            selectionModel?.clear()
        }
    }
    @Published var searchString: String = "" {
        didSet {
            Task { await doFilter() }
        }
    }
    @Published var filteredMedia: [VideoItem] = []
    
    func setSelectionModel(_ model: SelectionModel<VideoItem>) {
        selectionModel = model
    }
    
    /// Select all items, it's expensive.
    func selectAll() {
        for video in videos {
            video.isSelected = true
        }
        selectionModel?.select(videos)
    }
    
    /// Deselect all items, expensive too.
    func deSelectAll() {
        for video in videos {
            video.isSelected = false
        }
        selectionModel?.deselect()
    }
    
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
