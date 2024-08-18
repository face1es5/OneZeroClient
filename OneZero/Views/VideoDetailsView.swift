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
        TabView {
            UploadTaskView()
                .tabItem {
                    Label("Tasks queue", systemImage: "hammer")
                }
                .badge(2)
                .padding()
            if selectionModel.selectedItem != nil {
                VideoDetailsView(video: selectionModel.selectedItem!)
                    .tabItem {
                        Label("Media detail", systemImage: "mediastick")
                    }
                    .badge(2)
                    .padding()
            } else {
                Text("No video selected.")
                    .font(.title2)
                    .tabItem {
                        Label("Media detail", systemImage: "mediastick")
                    }
                    .badge(2)
                    .padding()
            }

            CollectionView()
                .tabItem {
                    Label("Collection detail", systemImage: "photo.stack")
                }
                .badge(2)
                .padding()
        }
        .padding(0)
    }
}

struct CollectionView: View {
    @EnvironmentObject var selectionModel: SelectionModel<VideoItem>
    @State var totalSize: String = "Loading..."
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Select num: ")
                Text("\(selectionModel.count)")
            }
            .font(.title2)
            DisclosureGroup("info") {
                Form {
                    Field(key: "Total size", value: "\(totalSize)")
                        .onChange(of: selectionModel.selectedItems) { _ in
                            var size: Int64 = 0
                            for items in selectionModel.selectedItems {
                                size += items.meta.size
                            }
                            totalSize = size.formattedFileSize()
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .task {
                    var size: Int64 = 0
                    for items in selectionModel.selectedItems {
                        size += items.meta.size
                    }
                    totalSize = size.formattedFileSize()
                }
            }
        }
    }
    
}

struct UploadTaskView: View {
    @State var tasknum: Int = 0
    var body: some View {
        VStack {
            if tasknum == 0 {
                Text("No task.")
                    .font(.title2)
            } else {
                Text("Tasks: \(tasknum)")
            }
        }
    }
}

struct VideoDetailsView: View {
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
