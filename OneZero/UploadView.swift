//
//  UploadView.swift
//  OneZero
//
//  Created by Fish on 10/8/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

struct VideoThumbView: View {
    let url: URL
    
    init(from url: String) {
        self.url = URL(fileURLWithPath: url)
    }
    
    init(from url: URL) {
        self.url = url
    }
    
    @State var thumbnail: Image? = nil
    @State var fetching = true
    var body: some View {
        VStack {
            if fetching {
                ProgressView()
                    .frame(width: 200, height: 200)
            } else if thumbnail != nil {
                VStack {
                    thumbnail!
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
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
            Text(url.lastPathComponent).frame(maxWidth: 200)
        }
        .padding()
        .task {
            genThumbnail()
        }
    }
    
    func genThumbnail() {
        defer {
            fetching = false
        }
        print("generating image thumbnail from \(url)")
        let asset = AVURLAsset(url: self.url, options: nil)
        let img_gen = AVAssetImageGenerator(asset: asset)
        img_gen.appliesPreferredTrackTransform = true
        DispatchQueue.global().async {
            do {
                let cgImg = try img_gen.copyCGImage(at: CMTime(seconds: 1.0, preferredTimescale: 60), actualTime: nil)
                thumbnail = Image(cgImg, scale: 1.0, orientation: .up, label: Text(url.lastPathComponent))
            } catch let error {
                print("Some error occurs while generating thumbnail of url arrow.clockwise\(url): \(error)")
            }
        }
    }
}

struct UploadView: View {
    @State var files: [URL] = []
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("choose files:")
                Button(action: {    // select files.
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = true
                    panel.canChooseFiles = true
                    panel.canChooseDirectories = false
                    panel.allowedContentTypes = [UTType.video, UTType.movie, UTType.avi]
                    if panel.runModal() == .OK {
                        files = panel.urls
                    }
                }) {
                    Image(systemName: "folder")
                }
            }
            Text("Selected files: ")
            ScrollView(showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach($files, id:\.self) { $url in
                        VideoThumbView(from: url)
                    }
                }
            }

        }
        .navigationTitle("Upload videos")
        .padding()
        .toolbar {
            Button(action: {
                DispatchQueue.global().async {
                    upload()
                }
            }) {
                Label("upload videos.", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    func upload() {
        print("Uploading in thread: \(Thread.current)")
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
        VideoThumbView(from: "file:///Users/fish/Desktop/sample.mp4")
    }
}

