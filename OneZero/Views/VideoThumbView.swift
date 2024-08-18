//
//  VideoThumbView.swift
//  OneZero
//
//  Created by Fish on 14/8/2024.
//

import AVFoundation
import SwiftUI

struct VideoThumbView: View {
    @ObservedObject var video: VideoItem
    @State var frame: CGRect = .zero
    
    var body: some View {
        ZStack(alignment: .center) {
            if video.uploading {
                ProgressView()
                    .zIndex(1)
            }
            VStack(spacing: 10) {
                if video.loadingThumb {
                    ProgressView()
                } else if video.thumbnail == nil {
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
                video.thumbnail?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .blur(radius: video.uploading ? 10 : 0)
                    .padding()
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(video.isSelected ? .gray.opacity(0.5) : Color.clear, lineWidth: 16)
                    )
                Text(video.name)
                    .padding(2)
                    .cornerRadius(10)
                    .background(video.isSelected ? .accentColor.opacity(0.5) : Color.clear)
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
                    .preference(key: VideoFrameKey.self, value: [video.id: geo.frame(in: .global)])
                    .onAppear {
                        frame = geo.frame(in: .global)
                    }
            }
        )
        .contextMenu {
            Button("Preview") { // popover to preview media
                print("preview.")
                let preview = MediaPreview(media: video)
                let hostingController = NSHostingController(rootView: preview)
                let popover = NSPopover()
                popover.contentViewController = hostingController
                popover.behavior = .transient
                if let wind = NSApp.mainWindow {
                    popover.show(relativeTo: frame, of: wind.contentView!, preferredEdge: .minY)
                }
            }
            Button("Upload") {  // upload selected video
                Task.detached(priority: .background) {
                    await Uploader.shared.upload(for: video, to: "api/upload")
                }
            }
            Divider()
            Button("Refresh thumbnail") {   //  force to refresh thumbnail
                refreshThumbnail(true)
            }
        }
        .disabled(!video.isSelected)
    }
    
    func refreshThumbnail(_ force: Bool = false) {
        if video.thumbnail == nil || force {
            Task { await video.genThumbnail() }
        }
    }
}

struct TestThumbView: View {
    @State var video = VideoItem(from: "file:///Users/fish/Desktop/sample.mp4")
    var body: some View {
        VideoThumbView(video: video)
    }
}

struct VideoThumbView_Previews: PreviewProvider {
    static var previews: some View {
        TestThumbView()
    }
}
