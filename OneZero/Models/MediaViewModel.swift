//
//  MediaViewModel.swift
//  OneZero
//
//  Created by Fish on 14/8/2024.
//

import Foundation

/// A View Model holds a collection of media, **also it has a internal selectionModel reference**.
///
/// **Any modification on internal items will clear selection.**
class MediaViewModel: ObservableObject {
    private var selectionModel: SelectionModel<MediaItem>?
    @Published var someMedia: [MediaItem] = [] {
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
    @Published var filteredMedia: [MediaItem] = []
    
    func setSelectionModel(_ model: SelectionModel<MediaItem>) {
        selectionModel = model
    }
    
    /// Select all items, it's expensive.
    func selectAll() {
        for media in someMedia {
            media.isSelected = true
        }
        selectionModel?.select(someMedia)
    }
    
    /// Deselect all items, expensive too.
    func deSelectAll() {
        for media in someMedia {
            media.isSelected = false
        }
        selectionModel?.deselect()
    }
    
    private func filterMedia() async -> [MediaItem] {
        guard !searchString.isEmpty else { return someMedia }
        return someMedia.filter {
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
    
    func load(from items: [MediaItem]) {
        someMedia = items
    }
    
    func load(from urls: [URL]) {
        someMedia = urls.map { MediaFactory.createMedia(from: $0) }
    }

    func load(from urls: [String]) {
        someMedia = urls.map { MediaFactory.createMedia(from: $0) }
    }

    func count() -> Int { return someMedia.count }
    func clear() { someMedia = [] }
}


