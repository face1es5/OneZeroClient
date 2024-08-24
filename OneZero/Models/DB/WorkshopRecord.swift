//
//  WorkshopRecord.swift
//  OneZero
//
//  Created by Fish on 22/8/2024.
//

import Foundation

enum WorkCategory: String, CaseIterable, Identifiable, Codable, Equatable {
    case all, wedding, advocacy, interview, advertising
    var id: Self { self }
    var localizedString: String {
        return NSLocalizedString(self.rawValue.capitalized, comment: "")
    }
}

struct WorkshopRecord: Codable {
    var id: String
    let title: String
    let description: String
    let media: [MediaRecord]
    var category: WorkCategory = .all
    
    func toModel() -> WorkshopItem {
        .init(id: id, title: title, description: description, mediaRecords: media, category: category)
    }
}
