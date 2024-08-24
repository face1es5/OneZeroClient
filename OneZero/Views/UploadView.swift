//
//  UploadView.swift
//  OneZero
//
//  Created by Fish on 10/8/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct MediaFrameKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

struct UploadView: View {
    @EnvironmentObject var mediaViewModel: MediaViewModel
    @EnvironmentObject var selectionModel: SelectionModel<MediaItem>
    @EnvironmentObject var appViewModel: AppViewModel
    @State var selectionRect: CGRect = .zero
    @State var isSelecting: Bool = false
    @State private var mediaFrames: [UUID: CGRect] = [:]
    @State private var baseOffset: CGRect?

    var body: some View {
        ZStack {
            Rectangle()
                .strokeBorder(.blue, lineWidth: 2)
                .background(.blue.opacity(0.2))
                .frame(width: selectionRect.width, height: selectionRect.height)
                .position(x: selectionRect.midX, y: selectionRect.midY)
                .opacity(isSelecting ? 1 : 0)
                .zIndex(1)
            ScrollView {
                MediaGalleryView()
                    .navigationTitle("Upload items")
                    .toolbar {
                        ToolbarItemGroup(placement: .automatic) {
                            Button(action: { // select files.
                                let panel = NSOpenPanel()
                                panel.allowsMultipleSelection = true
                                panel.canChooseFiles = true
                                panel.canChooseDirectories = false
                                panel.allowedContentTypes = [UTType.video, UTType.movie, UTType.avi, UTType.image, UTType.png, UTType.jpeg, UTType.gif]
                                if panel.runModal() == .OK {
                                    mediaViewModel.load(from: panel.urls)
                                }
                            }) {
                                Image(systemName: "photo.on.rectangle")
                            }
                            .help("Select items to upload")
                            .keyboardShortcut("i", modifiers: .command)
                            
//                            Button(action: {
//                                Task {
//                                    await upload()
//                                }
//                            }) {
//                                Image(systemName: "square.and.arrow.up")
//                            }
//                            .help("Upload selected items")
//                            .disabled(selectionModel.hasSelection == false)
//                            .keyboardShortcut("u", modifiers: .command)
                            SubmitWorkButton()
                            
                            Button(action: { withAnimation { appViewModel.showRightPanel.toggle() } }) {
                                Label("Show or Hide right panel", systemImage: "sidebar.right")
                            }
                            .help("Show or Hide right panel")
                            .keyboardShortcut("s", modifiers: .command)
                        }
                    }
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .contentShape(Rectangle())
                                .simultaneousGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            // creates rect on first dragging
                                            let offsetPoint = geo.frame(in: .global).origin
                                            // ... even not scroll, geo has an initial offset, so add it...
                                            let base = CGPoint(
                                                x: offsetPoint.x - (baseOffset?.minX ?? 0),
                                                y: offsetPoint.y - (baseOffset?.minY ?? 0)
                                            )
//                                            print("base geo: \(base)")
//                                            print("offset geo: \(baseOffset ?? .zero)")
                                            
                                            let startPoint: CGPoint = CGPoint(
                                                x: value.startLocation.x + base.x,
                                                y: value.startLocation.y + base.y
                                            )
                                            let currentPoint: CGPoint = CGPoint(
                                                x: value.location.x + base.x,
                                                y: value.location.y + base.y
                                            )
//                                            print("startPoint: \(startPoint)")
//                                            print("currentPoint: \(currentPoint)")
                                            if !isSelecting {
                                                isSelecting = true
                                                selectionRect = CGRect(
                                                    x: startPoint.x,
                                                    y: startPoint.y,
                                                    width: 0,
                                                    height: 0
                                                )
                                            }
                                            /**
                                             update rect when dragging
                                             1. update size
                                             2. update the origin
                                             Cause we expect the rectangle can be selected in four-way(.i.e ne/se/sw/nw), so we should choose min origin between source and current, traditionally, the CGRect will extend to the southeast.
                                             We can assume the rectangle has a fixed source point(in this case, the source point is value.startLocation instead of rect's origin, because origin will change during dragging), then we need to calculate position of rect's left corner(mentioned above, rect will draw along the lower right).
                                             So choose the min value of the source coord and current coord(two dimension).
                                             **Fix**
                                             When rectangle is shown in a scroll view, it's origin point coord will be incorrect, to fix this we have to convert the start point relative to scrollview.
                                             */
                                            //
                                            selectionRect.size = CGSize(
                                                width: abs(currentPoint.x - startPoint.x),
                                                height: abs(currentPoint.y - startPoint.y)
                                            )
                                            selectionRect.origin = CGPoint(
                                                x: min(currentPoint.x, startPoint.x),
                                                y: min(currentPoint.y, startPoint.y)
                                            )
                                        }
                                        .onEnded { value in
                                            isSelecting = false
                                            let basePoint = CGPoint(x: 220, y: 52)
                                            var realRect = selectionRect
                                            // selectionRect is relative to gallery view, but mediaFrame is global, so we need to make selectionRect's coord global.
                                            realRect.origin = CGPoint(
                                                x: realRect.minX + basePoint.x,
                                                y: realRect.minY + basePoint.y
                                            )
//                                            print("------\nreal rect: \(realRect)")
                                            // deselect previous selection and select current selection.
                                            for item in selectionModel.selectedItems {
                                                item.isSelected.toggle()
                                            }
                                            var selectedItems: [MediaItem] = []
                                            for (id, frame) in mediaFrames {
                                                if realRect.intersects(frame) {
                                                    if let item = mediaViewModel.filteredMedia.first(where: { $0.id == id }) {
                                                        item.isSelected = true
                                                        selectedItems.append(item)
//                                                        if !video.isSelected {
//                                                            print("selected video: \(video.name), \(frame.origin)")
//                                                            selectionModel.select(video)
//                                                            video.isSelected.toggle()
//                                                        }
                                                    }
                                                }
                                            }
                                            selectionModel.select(selectedItems)
//                                            print("------\n")
                                        }
                                )
                        }
                    )
                    .onPreferenceChange(MediaFrameKey.self) { preferences in
                        mediaFrames = preferences
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .contextMenu {
            Button("Upload selected items") {
                Task.detached { await upload() }
            }
            .disabled(selectionModel.hasSelection == false)
            Divider()
            Button("Select all") {
                mediaViewModel.selectAll()
            }
            .keyboardShortcut("a")
            Button("Deselect all") {
                mediaViewModel.deSelectAll()
            }
            Divider()
            Button("Clear all items") {
                mediaViewModel.clear()
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    // Assign base offset of scrollview, **not completed**, it's only the initial coord of scrollview, but if change size of scrollview(like, move splitter of leftsidebar), it will be incorrect, but next time when app restarts or view re-appear it's correct(as it reads initial coord every time on appear).
                    baseOffset = geo.frame(in: .global)
                }
            }
        )
    }

    func upload() async {
        if !selectionModel.hasSelection { print("No item selected."); return }
        UploadManager.shared.uploadRequest(for: selectionModel.selectedItems, to: "api/upload")
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
    }
}
