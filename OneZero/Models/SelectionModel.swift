//
//  SelectionModel.swift
//  OneZero
//
//  Created by Fish on 15/8/2024.
//

import Foundation

class SelectionModel<T: Hashable>: ObservableObject, Sequence {
    @Published var selectedItems: Set<T> = []
    
    @Published var selectedItem: T? = nil
    
    var count: Int {
        selectedItems.count
    }
    
    func makeIterator() -> Set<T>.Iterator {
        return selectedItems.makeIterator()
    }
    
    func hasSelection() -> Bool {
        return selectedItem != nil
    }
    
    func deselect() {
        selectedItem = nil
    }
    
    func select(_ item: T) {
        selectedItem = item
    }
}
