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
    @EnvironmentObject var commonSettings: CommonSettings
    @State var totalSize: String = "Loading..."
    @State var isPresented: Bool = false
    
    var body: some View {
        ScrollView {
            HStack {
                Text("Select num: ")
                Text("\(selectionModel.count)")
            }
            .font(.title2)
            SubmitFormView(isPresented: $isPresented, pop: false)
            // Fuck you, fucking disclosure group
//            DisclosureGroup("info") {
//                Form {
//                    Field(key: "Total size", value: "\(totalSize)")
//                        .onChange(of: selectionModel.selectedItems) { _ in
//                            var size: Int64 = 0
//                            for items in selectionModel.selectedItems {
//                                size += items.meta.size
//                            }
//                            totalSize = size.formattedFileSize()
//                        }
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding()
//                .task {
//                    var size: Int64 = 0
//                    for items in selectionModel.selectedItems {
//                        size += items.meta.size
//                    }
//                    totalSize = size.formattedFileSize()
//                }
//            }
        }
    }
    
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView()
    }
}
