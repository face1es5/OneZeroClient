//
//  WorkshopItem.swift
//  OneZero
//
//  Created by Fish on 22/8/2024.
//

import Foundation

struct WorkshopItem: Encodable, Decodable {
    var id: String
    let title: String
    let description: String
    let media: [String]
}
