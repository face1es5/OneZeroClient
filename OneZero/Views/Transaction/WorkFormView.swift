//
//  WorkFormView.swift
//  OneZero
//
//  Created by Fish on 21/8/2024.
//

import SwiftUI

struct GalleriesPreview: View {
    @EnvironmentObject var selectionModel: SelectionModel<MediaItem>
    @State var selectedItems: [MediaItem] = []
    @State var showPreview: [Bool] = []

    var body: some View {
        ScrollView {
            VStack {
                ForEach(selectedItems.indices, id: \.self) { idx in
                    MediaThumbView(media: selectedItems[idx])
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .popover(isPresented: $showPreview[idx]) {
                            MediaPreview(media: selectedItems[idx])
                        }
                        .onTapGesture {
                            showPreview[idx].toggle()
                        }
                }
            }
            .padding()
        }
        .onAppear {
            selectedItems = selectionModel.itemsArray
            showPreview = selectedItems.map { _ in false }
        }
        .padding(0)
    }
}

struct WorkForm: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                SubmitFormView(isPresented: $isPresented, pop: true)
                .padding()
                HStack {
                    Divider()
                    GalleriesPreview()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(width: 600, height: 400)
    }
}

struct SubmitWorkButton: View {
    @EnvironmentObject var selectionModel: SelectionModel<MediaItem>
    @State private var showSheet: Bool = false
    var body: some View {
        Button(action: {
            showSheet = true
        }) {
            Image(systemName: "square.and.arrow.up")
        }
        .sheet(isPresented: $showSheet) {
            WorkForm(isPresented: $showSheet)
        }
        .help("Upload selected items")
        .disabled(selectionModel.hasSelection == false)
        .keyboardShortcut("u", modifiers: .command)
    }
}
