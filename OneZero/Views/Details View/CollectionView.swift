//
//  CollectionView.swift
//  OneZero
//
//  Created by Fish on 20/8/2024.
//

import SwiftUI

/// View for a collection of selected items.
///
struct CollectionView: View {
    @EnvironmentObject var selectionModel: SelectionModel<MediaItem>
    @State var totalSize: String = "Loading..."
    @State var title: String = ""
    @State var description: String = ""
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Select num: ")
                Text("\(selectionModel.count)")
            }
            .font(.title2)
            Form {
                TextField("Title:", text: $title)
                TextField("Description:", text: $description, axis: .vertical)
                    .lineLimit(10)
            }
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

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView()
    }
}
