//
//  VideoThumbView.swift
//  OneZero
//
//  Created by Fish on 14/8/2024.
//

import SwiftUI
import AVFoundation

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
            } catch {
                print("Some error occurs while generating thumbnail of url \(video.url): \(error)")
            }
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
