//
//  UploadView.swift
//  OneZero
//
//  Created by Fish on 10/8/2024.
//

import AVFoundation
import SwiftUI
import UniformTypeIdentifiers

struct VideoGalleryView: View {
    @EnvironmentObject var videoItems: VideoViewModel
    @EnvironmentObject private var selectionModel: SelectionModel<VideoItem>
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 20) {
                ForEach(videoItems.videos) { video in
                    VideoThumbView(video: video)
                        .background(selectionModel.contains(video) ? Color.accentColor : .clear)
                        .cornerRadius(15)
                        .onTapGesture {
                            if selectionModel.contains(video) { selectionModel.remove(video) }
                            else { selectionModel.insert(video) }
                        }
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
    }
}

struct UploadView: View {
    @ObservedObject var videoItems: VideoViewModel = VideoViewModel()
    @ObservedObject private var selectionModel: SelectionModel = SelectionModel<VideoItem>()

    var body: some View {
        VStack {
            VideoGalleryView()
        }
        .environmentObject(videoItems)
        .environmentObject(selectionModel)
        .navigationTitle("Upload videos")
        .padding()
        .toolbar {
            ToolbarItemGroup {
                Button(action: { // select files.
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = true
                    panel.canChooseFiles = true
                    panel.canChooseDirectories = false
                    panel.allowedContentTypes = [UTType.video, UTType.movie, UTType.avi]
                    if panel.runModal() == .OK {
                        videoItems.load(from: panel.urls)
                    }
                }) {
                    Image(systemName: "photo.on.rectangle")
                }
                Button(action: {
                    Task {
                        await upload()
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled((selectionModel.count > 0) ? false : true)
            }
        }
    }

    func upload() async {
        guard selectionModel.count > 0 else { print("No videos selected."); return }
        for video in selectionModel {
            Task {
                await Uploader.shared.upload(for: video, to: "api/upload")
            }
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
    }
}
