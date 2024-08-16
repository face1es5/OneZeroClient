//
//  ContentView.swift
//  OneZero
//
//  Created by Fish on 13/8/2024.
//

import SwiftUI

struct SidebarMenuItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
}

struct SidebarMenuGroups: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let menus: [SidebarMenuItem]
}

struct ContentView: View {
    @StateObject var videosViewModel: VideosViewModel = VideosViewModel()
    @StateObject var selectionModel: SelectionModel<VideoItem> = SelectionModel<VideoItem>()
    @StateObject var appViewModel: AppViewModel = AppViewModel()
    @State var selectedView: SidebarMenuItem?
    
    let sideBarGroups = [
        SidebarMenuGroups(name: "Administrator", menus: [
            SidebarMenuItem(name: "Upload", icon: "icloud.and.arrow.up")
        ]),
        SidebarMenuGroups(name: "1990.10.10", menus: [
            SidebarMenuItem(name: "Gallery_title", icon: "photo.on.rectangle.angled")
        ])
    ]


    var body: some View {
        NavigationSplitView {
            List(selection: $selectedView) {
                ForEach(sideBarGroups, id: \.self) { group in
                    Section(LocalizedStringKey(group.name)) {
                        ForEach(group.menus, id: \.self) { menu in
                            Label(LocalizedStringKey(menu.name), systemImage: menu.icon)
                                .tag(menu)
                        }
                    }
                }
            }
            .frame(width: 200)
            .navigationTitle("Sidebar")
        } detail: {
            HStack(spacing: 0) {
                if let selectedView {
                    switch selectedView.name {
                    case "Upload":
                        UploadView()
                    case "Gallery":
                        GalleryView()
                    default:
                        EmptyView()
                    }
                } else {
                    GalleryView()
                }
                if appViewModel.showRightPanel {
                    HStack {
                        Divider()
                        VideoDetailsView()
                    }
                    .transition(.move(edge: appViewModel.showRightPanel ? .trailing : .leading))
                    .frame(maxWidth: 200)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appViewModel.showRightPanel)
        }
        .environmentObject(videosViewModel)
        .environmentObject(selectionModel)
        .environmentObject(appViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
