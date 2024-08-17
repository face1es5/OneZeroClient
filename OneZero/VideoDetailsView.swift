//
//  VideoDetailsView.swift
//  OneZero
//
//  Created by Fish on 16/8/2024.
//

import SwiftUI

struct Field: View {
    let key: String,
        value: String
    var body: some View {
        Text(NSLocalizedString(key, comment: "") + ": " + NSLocalizedString(value, comment: ""))
    }
}
extension Form {
    func field(key: String, value: String) -> some View {
        self.overlay(Field(key: key, value: value))
    }
}

struct VideoDetailsView: View {
    @EnvironmentObject var selectionModel: SelectionModel<VideoItem>
    var body: some View {
        if selectionModel.selectedItem == nil {
            VStack {
                Text("Please select a video to show detail info.")
                   .frame(maxHeight: .infinity)
                   .font(.title2)
                Spacer()
            }

       } else {
            let video = selectionModel.selectedItem!
            ScrollView {
                VStack(alignment: .leading) {
                    Text(video.name)
                        .font(.title2)
                    DisclosureGroup("meta") {
                        Form {
                            Field(key: "size", value: video.meta.size)
                            Field(key: "duration(secs)", value: video.meta.duration)
                            Field(key: "resolution", value: video.meta.resolution)
                            Field(key: "creation date", value: video.meta.creationDate)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
}

struct VideoDetailsDemo: View {
    @State var video = VideoItem(from: "/Users/fish/Desktop/dodo.mp4")
    @State var isExpanded = false
    var body: some View {
        VStack(alignment: .leading) {
            Text(video.name)
                .font(.title2)
            DisclosureGroup("meta") {
                Text("duration: \(video.meta.duration)")
            }
        }
    }
}

struct VideoDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        VideoDetailsDemo()
    }
}
