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
struct MediaDetailsView: View {
    @ObservedObject var mediaItem: MediaItem
    @State var player: AVPlayer = AVPlayer()
    @State var showPreview: Bool = false
    init(media: MediaItem) {
        mediaItem = media
    }
    var body: some View {
        ScrollView {
            HStack {
                Label(mediaItem.name, systemImage: "folder.fill")
                .font(.title2)
                .help("Open file")
                .onTapGesture {
                    NSWorkspace.shared.open(mediaItem.url)
                }
                Button(action: {
                    do {
                        if try mediaItem.url.checkResourceIsReachable() {
                            NSWorkspace.shared.open(mediaItem.url.deletingLastPathComponent())
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
                TextField("Media title:", text: $mediaItem.title)
                TextField("Description:", text: $mediaItem.description, axis: .vertical)
                    .lineLimit(5)
                
            }
            if mediaItem is VideoItem {
                VideoPlayer(player: player)
                    .onAppear {
                        player = AVPlayer(url: mediaItem.url)
                    }
                    .onDisappear {
                        player.pause()
                    }
                    .onChange(of: mediaItem.url) { newURL in
                        player = AVPlayer(url: newURL)
                    }
                    .frame(height: 200)
            } else {
                mediaItem.thumbnail?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .popover(isPresented: $showPreview, arrowEdge: .leading) {
                        MediaPreview(media: mediaItem)
                    }
                    .onHover { hovering in
                        showPreview = hovering
                    }
            }

            DisclosureGroup("meta") {
                Form {
                    Field(key: "Size", value: mediaItem.meta.formattedSize)
                    Field(key: "Duration(secs)", value: mediaItem.meta.duration)
                    Field(key: "Resolution", value: mediaItem.meta.resolution)
                    Field(key: "Creation date", value: mediaItem.meta.creationDate)
                    Field(key: "Full path", value: mediaItem.url.urlDecode())
                        .help(mediaItem.url.urlDecode())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .lineLimit(1)
            }
            Spacer()
        }
    }
}

struct MediaDetailsView_Previews: PreviewProvider {
    static var previews: some View {
//        MediaDetailsView()
        EmptyView()
    }
}
