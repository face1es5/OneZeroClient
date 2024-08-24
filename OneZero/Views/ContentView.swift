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
    @EnvironmentObject var appViewModel: AppViewModel
    @State var selectedView: SidebarMenuItem?
    
    let sideBarGroups = [
        SidebarMenuGroups(name: "Administrator", menus: [
            SidebarMenuItem(name: "Upload", icon: "icloud.and.arrow.up")
        ]),
        SidebarMenuGroups(name: "1990.10.10", menus: [
            SidebarMenuItem(name: "Gallery title", icon: "photo.on.rectangle.angled"),
            SidebarMenuItem(name: "Photographic tidbits", icon: "camera.viewfinder")
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
                        if appViewModel.showRightPanel {
                            HStack {
                                Divider()
                                DetailsView()
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                            .transition(.move(edge: appViewModel.showRightPanel ? .trailing : .leading))
                            .frame(maxWidth: 300)
                        }
                    case "Gallery title":
                        GalleryView()
                            .navigationTitle("Gallery")
                    case "Photographic tidbits":
                        GalleryView()
                            .navigationTitle("Phogallery")
                    default:
                        EmptyView()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appViewModel.showRightPanel)
        }
        .onAppear {
            selectedView = sideBarGroups[1].menus.first
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
