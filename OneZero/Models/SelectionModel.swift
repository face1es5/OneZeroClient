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
    var itemsArray: [T] {
        Array(selectedItems)
    }
    var count: Int {
        selectedItems.count
    }
    
    func makeIterator() -> Set<T>.Iterator {
        return selectedItems.makeIterator()
    }
    
    var hasSelection: Bool {
        selectedItem != nil || selectedItems.count > 0
    }
    
    /**
     Deselect selectedItem and selectedItems.
     */
    func deselect() {
        guard selectedItem != nil else { return }
        selectedItems.remove(selectedItem!)
        selectedItem = nil
    }
    
    /**
     Select target item, **this will deselect previous selection**.
     */
    func select(_ item: T) {
        selectedItem = item
        selectedItems = [item]
    }
    
    /**
     Select **items, this will deselect previous selection.**
     */
    func select(_ items: [T]) {
        selectedItems = Set(items)
        selectedItem = selectedItems.first
    }
    
    func clear() {
        selectedItems = []
        selectedItem = nil
    }
}
