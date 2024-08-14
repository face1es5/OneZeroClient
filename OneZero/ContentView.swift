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

struct ContentView: View {
    let sideBarMenus = [
        SidebarMenuItem(name: "Upload", icon: "icloud.and.arrow.up"),
        SidebarMenuItem(name: "Gallery", icon: "photo.on.rectangle.angled"),
    ]
    
    @State var selectedView: SidebarMenuItem?
    
    var body: some View {
        NavigationSplitView {
            VStack {
                List(selection: $selectedView) {
                    ForEach(sideBarMenus, id: \.self) { menu in
                        HStack(spacing: 20) {
                            Image(systemName: menu.icon)
                                .resizable()
                                .scaledToFit()
                            Text(menu.name)
                                .font(.title3)
                        }
                        .padding()
                        .frame(maxHeight: 50)
                    }
                }
                .frame(width: 200)
                .navigationTitle("Sidebar")
            }

        } detail: {
            if let selectedView {
                switch selectedView.name {
                case "Upload" :
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
