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
    let sideBarGroups = [
        SidebarMenuGroups(name: "Administrator", menus: [
            SidebarMenuItem(name: "Upload", icon: "icloud.and.arrow.up")
        ]),
        SidebarMenuGroups(name: "1990.10.10", menus: [
            SidebarMenuItem(name: "Gallery", icon: "photo.on.rectangle.angled")
        ])
    ]

    @State var selectedView: SidebarMenuItem?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedView) {
                ForEach(sideBarGroups, id: \.self) { group in
                    Section(group.name) {
                        ForEach(group.menus, id: \.self) { menu in
                            Label(menu.name, systemImage: menu.icon)
                                .tag(menu)
                        }
                    }
                }
            }
            .frame(width: 200)
            .navigationTitle("Sidebar")
        } detail: {
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
        }
        .environmentObject(videosViewModel)
        .environmentObject(selectionModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
