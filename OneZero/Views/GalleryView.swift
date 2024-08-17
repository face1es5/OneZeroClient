//
//  GalleryView.swift
//  OneZero
//
//  Created by Fish on 10/8/2024.
//

import SwiftUI

struct GalleryView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    var body: some View {
        VStack {
            Text("This is fucking gallery...")
        }
        .navigationTitle("Gallery")
        .toolbar {
            ToolbarItemGroup {
                Button(action: { withAnimation { appViewModel.showRightPanel.toggle() } }) {
                    Label("Show/Hide right panel", systemImage: "sidebar.right")
                }
                .help("Show/Hide right panel")
                .keyboardShortcut("s", modifiers: .command)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryView()
    }
}
