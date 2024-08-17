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
    
    var hasSelection: Bool {
        selectedItem != nil || selectedItems.count > 0
    }
    
    func deselect() {
        guard selectedItem != nil else { return }
        selectedItems.remove(selectedItem!)
        selectedItem = nil
    }
    
    func select(_ item: T) {
        selectedItem = item
        selectedItems = [item]
    }
    
    func clear() {
        selectedItems = []
        selectedItem = nil
    }
}
