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
    @StateObject var pagesViewModel = PagesViewModel()
    @State var num: Int = 0
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                Pager(page: page, data: Array(0..<pagesViewModel.totalPageNum), id: \.self) { pageIndex in
                    GalleryPageView(
                        pageIndex: pageIndex, numPerPage: numPerPage
                    )
                }
                .alignment(.start)
                #if os(macOS)
                .disableDragging()
                #endif
                .itemSpacing(20)
                .frame(width: proxy.size.width, height: proxy.size.height)
                PageController(page: page, currentPage: $pagesViewModel.currentPage, pageSize: pagesViewModel.totalPageNum)
                    .padding()
                    .frame(alignment: .bottom)
            }
        }
        .environmentObject(pagesViewModel)
        .frame(maxWidth: .infinity)
        .task {
            pagesViewModel.totalPageNum = await queryPageSize()
        }
        .toolbar {
            ToolbarItemGroup {
                Picker("Category:", selection: $pagesViewModel.categoryFilter) {
                    ForEach(WorkCategory.allCases) { cate in
                        Text(cate.localizedString)
                    }
                }
            }
        }
        .searchable(text: $pagesViewModel.searchString, prompt: Text("Search..."))
        .onSubmit(of: .search) {
            Task {
                await doFilter()
            }
        }
        .onChange(of: pagesViewModel.categoryFilter) { cate in
            print("new cate is: \(cate.rawValue)")
            Task {
                await doFilter()
            }
        }
    }
    
    /// wrapper for queryPageSize, request page size from server and assign to pagesViewModel's totalPageNum
    ///
    /// Notice: although sometimes totalPageNum will not change after filter, but this operation still be treated as updating for viewmodel,
    /// thus pages view will also update.
    func doFilter() async {
        let pageSize =  await Task.detached(priority:.background) {
            return await queryPageSize()
        }.value
        await MainActor.run {
            pagesViewModel.totalPageNum = pageSize
            print("update page num to: \(pagesViewModel.totalPageNum)")
        }
    }
    
    func queryPageSize() async -> Int {
        do {
            var api: String = "\(commenSettings.baseURL)/workshop/page/size?per=\(numPerPage)"
            if pagesViewModel.searchString.count > 0 {
                api += "&kw=\(pagesViewModel.searchString)"
            }
            if pagesViewModel.categoryFilter != .all {
                api += "&category=\(pagesViewModel.categoryFilter.rawValue)"
            }
            print("fetching page size on \(api)")
            let pageJson: PageJson = try await APIService(to: api).getJSON()
            print("page size: \(pageJson.size)")
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
