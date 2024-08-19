//
//  MediaDetailsView.swift
//  OneZero
//
//  Created by Fish on 20/8/2024.
//

import SwiftUI
import AVKit

/// Media Details View for video&image.
///
/// TODO: support image.
struct MediaDetailsView: View {
    @ObservedObject var video: VideoItem
    var body: some View {
        ScrollView {
            HStack {
                Label(video.name, systemImage: "folder.fill")
                .font(.title2)
                .help("Open file")
                .onTapGesture {
                    NSWorkspace.shared.open(video.url)
                }
                Button(action: {
                    do {
                        if try video.url.checkResourceIsReachable() {
                            NSWorkspace.shared.open(video.url.deletingLastPathComponent())
                        }
                    } catch {}
                }) {
                    Image(systemName: "arrowshape.right.fill")
                        .resizable()
                        .frame(width: 12, height: 12)
                }
                .help("Open in finder")
                .buttonStyle(PlainButtonStyle())
            }

            Form {
                TextField("title:", text: $video.title)
                TextField("description:", text: $video.description)
            }
            VideoPlayer(player: AVPlayer(url: video.url))
                .frame(height: 200)
            DisclosureGroup("meta") {
                Form {
                    Field(key: "Size", value: video.meta.formattedSize)
                    Field(key: "Duration(secs)", value: video.meta.duration)
                    Field(key: "Resolution", value: video.meta.resolution)
                    Field(key: "Creation date", value: video.meta.creationDate)
                    Field(key: "Full path", value: video.url.urlDecode())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .lineLimit(1)
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
                Spacer()
            }
        }
        .frame(width: 200)
    }
}

struct MediaDetailsView_Previews: PreviewProvider {
    static var previews: some View {
//        MediaDetailsView()
        EmptyView()
    }
}
