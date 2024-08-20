//
//  MediaPreview.swift
//  OneZero
//
//  Created by Fish on 18/8/2024.
//

import SwiftUI
import AVKit

struct MediaPreview: View {
    var media: VideoItem
    var body: some View {
        VStack {
            Text("\(media.name)").font(.title2)
            Label("\(media.url.urlDecode())", systemImage: "network")
            media.thumbnail
        }
        .padding()
    }
}

struct VideoPreview: View {
    var video: VideoItem
    var body: some View {
        VStack {
            Text("\(video.name)").font(.title2)
            Label("\(video.url.urlDecode())", systemImage: "network")
            VideoPlayer(player: AVPlayer(url: video.url))
        }
        .padding()
    }
}

struct MediaPreview_Previews: PreviewProvider {
    static var previews: some View {
        MediaPreview(media: VideoItem(from: ""))
    }
}
