//
//  MediaThumbView.swift
//  OneZero
//
//  Created by Fish on 14/8/2024.
//

import AVFoundation
import SwiftUI

struct MediaThumbView: View {
    @ObservedObject var media: MediaItem
    @State var frame: CGRect = .zero
    
    var body: some View {
        ZStack(alignment: .center) {
            if media.uploading {
                ProgressView()
                    .zIndex(1)
            }
            VStack(spacing: 10) {
                if media.loadingThumb {
                    ProgressView()
                } else if media.thumbnail == nil {
                    Button(action: {
                        refreshThumbnail()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                media.thumbnail?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .blur(radius: media.uploading ? 10 : 0)
                    .padding()
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(media.isSelected ? .gray.opacity(0.5) : Color.clear, lineWidth: 10)
                    )
                Text(media.name)
                    .padding(2)
                    .cornerRadius(10)
                    .background(media.isSelected ? .accentColor.opacity(0.5) : Color.clear)
            }
            .padding()
            .task {
                refreshThumbnail()
            }
        }
        .frame(maxWidth: 200, maxHeight: 200)
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: MediaFrameKey.self, value: [media.id: geo.frame(in: .global)])
                    .onAppear {
                        frame = geo.frame(in: .global)
                    }
            }
        )
        .contextMenu {
            Button("Preview") { // popover to preview media
                let preview = MediaPreview(media: media)
                let hostingController = NSHostingController(rootView: preview)
                let popover = NSPopover()
                popover.contentViewController = hostingController
                popover.behavior = .transient
                if let wind = NSApp.mainWindow {
                    popover.show(relativeTo: frame, of: wind.contentView!, preferredEdge: .maxX)
                }
            }
            Button("Upload") {  // upload selected media
                UploadManager.shared.uploadRequest(for: media, to: "api/upload")
            }
            Divider()
            Button("Refresh thumbnail") {   //  force to refresh thumbnail
                refreshThumbnail(true)
            }
        }
        .disabled(!media.isSelected)
    }
    
    func refreshThumbnail(_ force: Bool = false) {
        if media.thumbnail == nil || force {
            Task { await media.genThumbnail() }
        }
    }
}

struct MediaThumbView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
