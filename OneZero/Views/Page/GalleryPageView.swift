//
//  GalleryPageView.swift
//  OneZero
//
//  Created by Fish on 24/8/2024.
//

import SwiftUI
import SwiftUIPager

struct GalleryPageView: View {
    @EnvironmentObject var commonSettings: CommonSettings
    @Binding var searchString: String
    @Binding var categoryFilter: WorkCategory
    let page: Page
    let pageIndex: Int
    let numPerPage: Int
    let pageSize: Int
    @State var works: [WorkshopItem] = []
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 400))], spacing: 10) {
                ForEach( works.filter{ $0.conform(kw: searchString, category: categoryFilter) } ) { work in
                    WorkshopThumView(work: work)
                }
            }
            .task {
                works = await fetchingWorks()
            }
            PageController(page: page, pageIndex: pageIndex, pageSize: pageSize)
                .padding()
        }
        .onChange(of: categoryFilter) { _ in
            let ws = works.filter{ $0.conform(kw: searchString, category: categoryFilter) }
            print(111)
        }
        
    }
    private func fetchingWorks() async -> [WorkshopItem] {
        print("get page record")
        do {
            var api: String = "\(commonSettings.baseURL)/workshop/?page=\(pageIndex+1)&per=\(numPerPage)"
            if searchString.count > 0 {
                api += "&kw=\(searchString)"
            }
            if categoryFilter != .all {
                api += "&category=\(categoryFilter.rawValue)"
            }
            let url = "\(commonSettings.baseURL)/workshop?page=\(pageIndex+1)&per=\(numPerPage)&kw=\(searchString)&category=\(categoryFilter.rawValue)"
            print("fetching url: \(url)")
            let workRecords: [WorkshopRecord] = try await APIService(to: url).getJSON() as [WorkshopRecord]
            print("load page \(pageIndex) success")
            return workRecords.map { $0.toModel() }
        } catch {
            print("error: \(error)")
        }
        return []
    }
}
