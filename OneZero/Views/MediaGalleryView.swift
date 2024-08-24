//
//  MediaGalleryView.swift
//  OneZero
//
//  Created by Fish on 18/8/2024.
//

import SwiftUI

/// For upload.
struct MediaGalleryView: View {
    @EnvironmentObject var mediaViewModel: MediaViewModel
    @EnvironmentObject var selectionModel: SelectionModel<MediaItem>
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 10) {
            ForEach(mediaViewModel.filteredMedia) { media in
                MediaThumbView(media: media)
                    .onTapGesture {
                        /**
                         we should:
                            1. clear previous selection (clear collection and make selectedItem is nil)
                            2. set current selected
                            3. update state of current(except it's already selected previous)
                         */
                        if !media.isSelected || selectionModel.count > 0 {
                            // if pre selected isn't cur, deselect pre and remove it from collection
                            for media in selectionModel.selectedItems { media.isSelected.toggle() }
                            // then select self.
                            selectionModel.select(media)
                            media.isSelected.toggle()
                        }
                    }
            }
        }
        .padding(.horizontal)
        .searchable(text: $mediaViewModel.searchString)
        .onAppear {
            mediaViewModel.setSelectionModel(selectionModel)
        }
    }
}
