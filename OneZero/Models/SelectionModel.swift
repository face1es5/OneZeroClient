//
//  SelectionModel.swift
//  OneZero
//
//  Created by Fish on 15/8/2024.
//

import Foundation

class SelectionModel<T: Hashable>: ObservableObject, Sequence {
    @Published var selectedItems: Set<T> = []
    
    var selectedItem: T? {
        selectedItems.first
    }

    var count: Int {
        selectedItems.count
    }

    func makeIterator() -> Set<T>.Iterator {
        return selectedItems.makeIterator()
    }

    func isSelected(_ item: T) -> Bool {
        return selectedItems.contains(item)
    }

    func deselect(_ item: T) {
        selectedItems.remove(item)
    }

    func select(_ item: T) {
        selectedItems.insert(item)
    }
}
