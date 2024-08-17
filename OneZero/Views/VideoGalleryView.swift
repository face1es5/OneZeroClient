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
                            1. clear previous selection (clear collection and make selectedItem is nil)
                            2. set current selected
                            3. update state of current(except it's already selected previous)
                         */
                        if !video.isSelected {
                            // if pre selected isn't cur, deselect pre and remove it from collection
                            selectionModel.selectedItem?.isSelected.toggle()
                            selectionModel.deselect()
                            // then select self.
                            selectionModel.select(video)
                            video.isSelected.toggle()
                        }
                    }
            }
        }
        .padding(.horizontal)
        .searchable(text: $videosViewModel.searchString)
        .onAppear {
            videosViewModel.setSelectionModel(selectionModel)
        }
    }
}


struct VideoGalleryView_Previews: PreviewProvider {
    static var previews: some View {
//        VideoGalleryView()
        EmptyView()
    }
}
