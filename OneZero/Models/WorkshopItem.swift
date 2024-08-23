//
//  WorkshopItem.swift
//  OneZero
//
//  Created by Fish on 22/8/2024.
//

import Foundation

struct WorkshopItem: Codable {
    var id: String
    let title: String
    let description: String
    let media: [MediaRecord]
}
