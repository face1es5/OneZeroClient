//
//  VideoItem.swift
//  OneZero
//
//  Created by Fish on 14/8/2024.
//

import Foundation

class VideoItem: Identifiable, Hashable, ObservableObject {
    let id = UUID().uuidString
    let url: URL
    let name: String
    @Published var loadingThumb: Bool = true
    @Published var uploading: Bool = false

    init(from url: URL) {
        self.url = url
        name = url.lastPathComponent
    }

    init(from url: String) {
        self.url = URL(fileURLWithPath: url)
        name = self.url.lastPathComponent
    }

    static func == (lhs: VideoItem, rhs: VideoItem) -> Bool {
        return lhs.id == rhs.id || lhs.url.absoluteString == rhs.url.absoluteString
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteString)
    }
}
