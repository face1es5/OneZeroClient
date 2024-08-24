//
//  WorkshopItem.swift
//  OneZero
//
//  Created by Fish on 23/8/2024.
//

import Foundation

class WorkshopItem: Identifiable, ObservableObject {
    let id: String
    @Published var title: String
    @Published var description: String
    var category: WorkCategory = .all
    var mediaItems: [MediaItem]
    
    init(id: String, title: String, description: String, mediaRecords: [MediaRecord], category: WorkCategory) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.mediaItems = mediaRecords.map { $0.toModel() }
    }
    
    func conform(kw: String, category: WorkCategory) -> Bool {
        var res = true
        if kw.count > 0 {
            res = title.contains(kw) || description.contains(kw)
        }
        if !res {
            return res
        }
        if category != .all {
            res = self.category == category
        }
        return res
    }
}
