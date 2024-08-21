//
//  MediaPreview.swift
//  OneZero
//
//  Created by Fish on 18/8/2024.
//

import SwiftUI
import AVKit

struct MediaPreview: View {
    var media: MediaItem
    var body: some View {
        VStack {
            Text("\(media.name)").font(.title2)
            Label("\(media.url.urlDecode())", systemImage: "network")
            if media is ImageItem {
                media.thumbnail?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 500, height: 500)
            } else if media is VideoItem {
                VideoPlayer(player: AVPlayer(url: media.url))
                    .frame(width: 500, height: 500)
                    .aspectRatio(contentMode: .fit)
            }

        }
        .padding()
    }
}

struct MediaPreview_Previews: PreviewProvider {
    static var previews: some View {
        MediaPreview(media: MediaItem(from: ""))
    }
}
