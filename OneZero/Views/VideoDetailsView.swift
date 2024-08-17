//
//  VideoDetailsView.swift
//  OneZero
//
//  Created by Fish on 16/8/2024.
//

import SwiftUI
import AVKit

struct Field: View {
    let key: String,
        value: String
    var body: some View {
        Text(NSLocalizedString(key, comment: "") + ": " + NSLocalizedString(value, comment: ""))
            .multilineTextAlignment(.leading)
    }
}
extension Form {
    func field(key: String, value: String) -> some View {
        self.overlay(Field(key: key, value: value))
    }
}

struct VideoDetailsContainer: View {
    @EnvironmentObject var selectionModel: SelectionModel<VideoItem>
    var body: some View {
        if selectionModel.selectedItem == nil {
            VStack(alignment: .leading) {
                Text("Please select a video to show detail info.")
                   .frame(maxHeight: .infinity)
                   .font(.title2)
            }
        } else {
            VideoDetailsView(video: selectionModel.selectedItem!)
        }
    }
}

struct VideoDetailsView: View {
    @ObservedObject var video: VideoItem
    var body: some View {
        ScrollView {
            Text(video.name)
                .font(.title2)
            Form {
                TextField("title:", text: $video.title)
                TextField("description:", text: $video.description)
            }
            VideoPlayer(player: AVPlayer(url: video.url))
                .frame(height: 200)
            DisclosureGroup("meta") {
                Form {
                    Field(key: "Size", value: video.meta.size)
                    Field(key: "Duration(secs)", value: video.meta.duration)
                    Field(key: "Resolution", value: video.meta.resolution)
                    Field(key: "Creation date", value: video.meta.creationDate)
                    Field(key: "Full path", value: video.url.urlDecode())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            Spacer()
        }
    }
}

struct VideoDetailsDemo: View {
    @State var video = VideoItem(from: "/Users/fish/Desktop/dodo.mp4")
    @State var isExpanded = false
    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Text(video.name)
                    .font(.title2)
                TextField("title:", text: $video.title)
                TextField("description:", text: $video.description)
                DisclosureGroup("meta") {
                    Text("duration: \(video.meta.duration)")
                }
            }
        }
        .frame(width: 200)
    }
}

struct VideoDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        VideoDetailsDemo()
    }
}
