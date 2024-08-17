//
//  VideoGalleryView.swift
//  OneZero
//
//  Created by Fish on 18/8/2024.
//

import SwiftUI

struct VideoGalleryView: View {
    @EnvironmentObject var videosViewModel: VideosViewModel
    @EnvironmentObject var selectionModel: SelectionModel<VideoItem>
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 10) {
            ForEach(videosViewModel.filteredMedia) { video in
                VideoThumbView(video: video)
                    .onTapGesture {
                        /**
                         we should:
                            1. clear previous selection (At this time, don't need to clear collection, just deactive previous selected item)
                            2. make current selected
                            3. update state of current
                            4. special exception: is selectedItem is self, deselect it
                         */
                        if video.isSelected {
                            // if self is current selection , deselect
                            selectionModel.deselect()
                        } else {
                            // if not, deselect pre
                            selectionModel.selectedItem?.isSelected.toggle()
                            // then select self.
                            selectionModel.select(video)
                        }
                        video.isSelected.toggle()
                    }
            }
        }
        .padding(.horizontal)
        .searchable(text: $videosViewModel.searchString)
    }
//    var filteredMedia: [VideoItem] {
//        guard !searchString.isEmpty else { return videosViewModel.videos }
////        print("applying search: \(searchString)")
//        return videosViewModel.videos.filter {
//            $0.name.lowercased().contains(searchString.lowercased())
//        }
//    }
}


struct VideoGalleryView_Previews: PreviewProvider {
    static var previews: some View {
//        VideoGalleryView()
        EmptyView()
    }
}
