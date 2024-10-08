//
//  DetailsView.swift
//  OneZero
//
//  Created by Fish on 16/8/2024.
//

import SwiftUI
import AVKit

struct DetailsView: View {
    @EnvironmentObject var selectionModel: SelectionModel<MediaItem>
    var body: some View {
        TabView {
            UploadTaskView()
                .tabItem {
                    Label("Tasks queue", systemImage: "hammer")
                }
                .badge(2)
                .padding()
            if selectionModel.selectedItem != nil {
                MediaDetailsView(media: selectionModel.selectedItem!)
                    .tabItem {
                        Label("Media detail", systemImage: "mediastick")
                    }
                    .badge(2)
                    .padding()
            } else {
                VStack {
                    Text("No item selected.")
                        .font(.title2)
                    Spacer()
                }
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

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView()
    }
}
