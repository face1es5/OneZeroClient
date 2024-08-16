//
//  VideoDetailsView.swift
//  OneZero
//
//  Created by Fish on 16/8/2024.
//

import SwiftUI

struct VideoDetailsView: View {
    @EnvironmentObject var selectionModel: SelectionModel<VideoItem>
    var body: some View {
        if selectionModel.selectedItem == nil {
            Text("Please select a video to show detail info.")
        } else {
            VStack {
                Text(selectionModel.selectedItem!.name)
            }
            .padding()
        }
    }
}

struct VideoDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        VideoDetailsView()
    }
}
