//
//  UploadView.swift
//  OneZero
//
//  Created by Fish on 10/8/2024.
//

import AVFoundation
import SwiftUI
import UniformTypeIdentifiers


struct UploadView: View {
    @AppStorage("api") var baseURL: String = ""
    @ObservedObject var videoItems: VideoViewModel = VideoViewModel()
    @State private var selectedItems: Set<VideoItem> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("choose files:")
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
                    Image(systemName: "folder")
                }
            }
            Text("Selected files: ")
            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(videoItems.videos) { video in
                        VideoThumbView(video: video)
                            .background(selectedItems.contains(video) ? Color.accentColor : .clear)
                            .cornerRadius(15)
                            .onTapGesture {
                                if selectedItems.contains(video) { selectedItems.remove(video) }
                                else { selectedItems.insert(video) }
                            }
                    }
                }
            }
        }
        .navigationTitle("Upload videos")
        .padding()
        .toolbar {
            Button(action: {
                Task {
                    await upload()
                }
            }) {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled((selectedItems.count > 0) ? false : true)
        }
    }

    func upload(for video: VideoItem) async throws {
        await MainActor.run {
            video.uploading = true
        }
        defer { Task { @MainActor in video.uploading = false } }

        // simulate loading data and uploading to server...
        print("Read Data.")
        let data = try Data(contentsOf: video.url)
        print("Ready to post on \(baseURL)")
        await APIService(to: "\(baseURL)/api/upload").postVideo(for: data, name: video.name) { result in
            switch result {
            case .success(let message):
                print("Upload \(video.name) success: \(message).")
            case .failure(let message):
                print("Upload \(video.name) failed: \(message)")
            }
        }
        
    }

    func upload() async {
        guard selectedItems.count > 0 else { print("No videos selected."); return }
        for video in selectedItems {
            Task {
                do {
                    try await upload(for: video)
                } catch {
                    print("Error when uploading \(video.name): \(error)")
                }
            }
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
    }
}
