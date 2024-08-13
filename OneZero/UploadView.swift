//
//  UploadView.swift
//  OneZero
//
//  Created by Fish on 10/8/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

class VideoItem: Identifiable, Hashable ,ObservableObject {
    let id = UUID().uuidString
    let url: URL
    let name: String
    @Published var loadingThumb: Bool = true
    @Published var uploading: Bool = false
    
    init(from url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }
    init(from url: String) {
        self.url = URL(fileURLWithPath: url)
        self.name = self.url.lastPathComponent
    }
    
    static func == (lhs: VideoItem, rhs: VideoItem) -> Bool {
        return lhs.id == rhs.id || lhs.url.absoluteString == rhs.url.absoluteString
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteString)
    }
}

class VideoViewModel: ObservableObject {
    @Published var videos: [VideoItem] = []
    
    func load(from urls: [URL]) {
        videos =  urls.map { VideoItem(from: $0) }
    }
    
    func load(from urls: [String]) {
        videos = urls.map { VideoItem(from: $0) }
    }
    
    func count() -> Int { return videos.count }
}

struct VideoThumbView: View {
    @ObservedObject var video: VideoItem
    @State var thumbnail: Image? = nil
    
    var body: some View {
        ZStack(alignment: .center) {
            if video.uploading {
                ProgressView()
                    .frame(width: 100, height: 100)
                    .zIndex(1)
            }
            VStack {
                if video.loadingThumb {
                    ProgressView()
                        .frame(width: 200, height: 200)
                } else if thumbnail != nil {
                    VStack {
                        thumbnail!
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                            .blur(radius: video.uploading ? 10 : 0)
                    }
                    .border(Color(NSColor.lightGray), width: 2)
                    .frame(width: 200, height: 200)

                } else {
                    Button(action: genThumbnail) {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 200, height: 200)
                }
                Text(video.name).frame(maxWidth: 200)
            }
            .padding()
            .task {
                genThumbnail()
            }
        }
    }
    
    func genThumbnail() {
        video.loadingThumb = true
        print("generating image thumbnail from \(video.url)")
        let asset = AVURLAsset(url: video.url, options: nil)
        let img_gen = AVAssetImageGenerator(asset: asset)
        img_gen.appliesPreferredTrackTransform = true
        DispatchQueue.global().async {
            defer {
                DispatchQueue.main.async {
                    video.loadingThumb = false
                }
            }
            do {
                let cgImg = try img_gen.copyCGImage(at: CMTime(seconds: 1.0, preferredTimescale: 60), actualTime: nil)
                DispatchQueue.main.async {
                    thumbnail = Image(cgImg, scale: 1.0, orientation: .up, label: Text(video.name))
                }
            } catch let error {
                print("Some error occurs while generating thumbnail of url \(video.url): \(error)")
            }
        }
    }
}

struct UploadView: View {
    @ObservedObject var videoItems: VideoViewModel = VideoViewModel()
    @State private var selectedItems: Set<VideoItem> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("choose files:")
                Button(action: {    // select files.
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
                            .background( selectedItems.contains(video) ? Color.accentColor : .clear)
                            .cornerRadius(15)
                            .onTapGesture {
                                if selectedItems.contains(video) { selectedItems.remove(video) }
                                else { selectedItems.insert(video) }}
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
            .disabled((selectedItems.count > 0) ? false: true)
        }
    }
    
    func upload(for video: VideoItem) async throws {
        await MainActor.run {
            video.uploading = true
        }
        defer { Task { @MainActor in video.uploading = false } }
        
        //simulate loading data and uploading to server...
//        let data = try Data(contentsOf: video.url)
        try await Task.sleep(nanoseconds: 2_000_000_000)
    }
    
    func upload() async {
        guard selectedItems.count > 0 else { print("No videos selected.");return }
        for video in selectedItems {
            Task {
                do {
                    try await upload(for: video)
                } catch let error {
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

