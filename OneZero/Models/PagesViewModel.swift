//
//  PagesViewModel.swift
//  OneZero
//
//  Created by Fish on 24/8/2024.
//

import Foundation

class PagesViewModel: ObservableObject {
    @Published var categoryFilter: WorkCategory = .all
    @Published var totalPageNum: Int = 0
    var searchString: String = ""
    var currentPage: Int = 1
}
