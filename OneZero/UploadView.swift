//
//  UploadView.swift
//  OneZero
//
//  Created by Fish on 10/8/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct VideoGalleryView: View {
    @EnvironmentObject var videosViewModel: VideosViewModel
    @EnvironmentObject var selectionModel: SelectionModel<VideoItem>
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 20) {
                ForEach(videosViewModel.videos) { video in
                    VideoThumbView(video: video)
                        .background(selectionModel.isSelected(video) ? Color.accentColor : .clear)
                        .cornerRadius(15)
                        .onTapGesture {
                            if selectionModel.isSelected(video) { selectionModel.deselect(video) }
                            else { selectionModel.select(video) }
                        }
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
    }
}

struct UploadView: View {
    @EnvironmentObject var videosViewModel: VideosViewModel
    @EnvironmentObject var selectionModel: SelectionModel<VideoItem>

    var body: some View {
        VStack {
            VideoGalleryView()
        }
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
                        videosViewModel.load(from: panel.urls)
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
