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
    @EnvironmentObject var pagesViewModel: PagesViewModel
    let pageIndex: Int
    let numPerPage: Int
    @State var works: [WorkshopItem] = []
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 400))], spacing: 10) {
                ForEach(works) { work in
                    WorkshopThumView(work: work)
                }
            }
            .task {
                await refresh()
            }
        }
        .contextMenu {
            Button("Refresh") {
                Task {
                    await refresh()
                }
            }
        }
        // have to observe filter manully as view is not related to these.
        .onChange(of: pagesViewModel.categoryFilter) { _ in
            Task {
                await refresh()
            }
        }
        .onChange(of: pagesViewModel.searchString) { _ in
            Task { await refresh() }
        }
    }
    
    private func refresh() async {
        let new = await Task.detached(priority: .background) {
            return await fetchingWorks()
        }.value
        
        await MainActor.run {
            works = new
        }
    }
    
    private func fetchingWorks() async -> [WorkshopItem] {
        print("get page record")
        do {
            let searchString = pagesViewModel.searchString
            let cateFilter = pagesViewModel.categoryFilter
            var api: String = "\(commonSettings.baseURL)/workshop/?page=\(pageIndex+1)&per=\(numPerPage)"
            if searchString.count > 0 {
                api += "&kw=\(searchString)"
            }
            if cateFilter != .all {
                api += "&category=\(cateFilter.rawValue)"
            }
            print("fetching url: \(api)")
            let workRecords: [WorkshopRecord] = try await APIService(to: api).getJSON() as [WorkshopRecord]
//            print("load page \(pageIndex) success")
            return workRecords.map { $0.toModel() }
        } catch {
            print("error: \(error)")
        }
        return []
    }
}
