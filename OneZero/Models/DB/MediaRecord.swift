//
//  MediaRecord.swift
//  OneZero
//
//  Created by Fish on 23/8/2024.
//

import Foundation

struct MediaRecord: Codable {
    let id: String
    let name: String
    let description: String
    let url: String
    let type: String
    
    func toModel() -> MediaItem {
        return MediaFactory.createRemoteMedia(from: url)
    }
}
