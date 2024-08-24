//
//  GalleryView.swift
//  OneZero
//
//  Created by Fish on 10/8/2024.
//

import SwiftUI
import SwiftUIPager

/// For user.
struct GalleryView: View {
    @StateObject var page: Page = .first()
    @EnvironmentObject var commenSettings: CommonSettings
    @AppStorage("numPerPage") var numPerPage: Int = 5
    @State var pageIndexes: [Int] = []
    @State var filteredPageIndexes: [Int] = []
    @State var searchString: String = ""
    @State var categoryFilter: WorkCategory = .all
    var body: some View {
        GeometryReader { proxy in
            Pager(page: page, data: pageIndexes, id: \.self) { pageIndex in
                GalleryPageView(
                    searchString: $searchString, categoryFilter: $categoryFilter,
                    page: page, pageIndex: pageIndex, numPerPage: numPerPage, pageSize: pageIndexes.count
                )
            }
            .alignment(.start)
            .itemSpacing(20)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .toolbar {
            ToolbarItem {
                Picker("Category:", selection: $categoryFilter) {
                    ForEach(WorkCategory.allCases) { cate in
                        Text(cate.localizedString)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .searchable(text: $searchString, prompt: Text("Search..."))
        .frame(maxWidth: .infinity)
        .task {
            let pageRange = await getPageRange()
            pageIndexes = pageRange
        }
        .onChange(of: categoryFilter) { cate in
            print("new cate is: \(cate.rawValue)")
            Task.detached(priority: .background) {
                let pageRange =  await getPageRange()
                DispatchQueue.main.async {
                    pageIndexes = pageRange
                }
            }
        }
        .onChange(of: searchString) { _ in
            Task.detached(priority: .background) {
                let pageRange =  await getPageRange()
                DispatchQueue.main.async {
                    pageIndexes = pageRange
                }
            }
        }
    }
    
    func getPageRange() async -> [Int] {
        let pageSize = await queryPageSize()
        return Array(0..<pageSize)
    }
    
    func queryPageSize() async -> Int {
        do {
            var api: String = "\(commenSettings.baseURL)/workshop/page/size?per=\(numPerPage)"
            if searchString.count > 0 {
                api += "&kw=\(searchString)"
            }
            if categoryFilter != .all {
                api += "&category=\(categoryFilter.rawValue)"
            }
            print("fetching page num on \(api)")
            let pageJson: PageJson = try await APIService(to: api).getJSON()
            print("page num: \(pageJson.size)")
//            pageIndexes = Array(0..<pageJson.size)
            return pageJson.size
        } catch {
            print("get page size failed: \(error)")
            return 0
        }
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
    }
}
