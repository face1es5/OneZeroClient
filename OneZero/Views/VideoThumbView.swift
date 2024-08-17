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
                    Button(action: video.genThumbnail) {
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
            .task { if video.thumbnail == nil { video.genThumbnail() }}
        }
        .frame(maxWidth: 200, maxHeight: 200)
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
