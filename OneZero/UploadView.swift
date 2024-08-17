//
//  UploadView.swift
//  OneZero
//
//  Created by Fish on 10/8/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct VideoGalleryView: View {
    @EnvironmentObject var videosViewModel: VideosViewModel
    @EnvironmentObject var selectionModel: SelectionModel<VideoItem>
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 10) {
            ForEach(videosViewModel.videos) { video in
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
    }
}

struct UploadView: View {
    @EnvironmentObject var videosViewModel: VideosViewModel
    @EnvironmentObject var selectionModel: SelectionModel<VideoItem>
    @EnvironmentObject var appViewModel: AppViewModel
    @State var selectionRect: CGRect = .zero
    @State var isSelecting: Bool = false

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
                VideoGalleryView()
                    .navigationTitle("Upload videos")
                    .toolbar {
                        ToolbarItemGroup(placement: .automatic) {
                            Button(action: { // select files.
                                let panel = NSOpenPanel()
                                panel.allowsMultipleSelection = true
                                panel.canChooseFiles = true
                                panel.canChooseDirectories = false
                                panel.allowedContentTypes = [UTType.video, UTType.movie, UTType.avi]
                                if panel.runModal() == .OK {
                                    videosViewModel.load(from: panel.urls)
                                }
                            }) {
                                Image(systemName: "photo.on.rectangle")
                            }.help("Select videos to upload")
                            
                            Button(action: {
                                Task {
                                    await upload()
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .help("Upload selected videos")
                            .disabled((selectionModel.count > 0) ? false : true)
                            Button(action: { withAnimation { appViewModel.showRightPanel.toggle() } }) {
                                Label("Show/Hide right panel", systemImage: "sidebar.right")
                            }
                            .help("Show/Hide right panel")
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
                                                x: offsetPoint.x - 201,
                                                y: offsetPoint.y - 52
                                            )
//                                            print("geo: \(base)")
                                            
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
//                                            print("Selection rect: \(selectionRect)")
                                            
                                        }
                                )
                            
                        }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .contextMenu {
            Button("clear") {
                videosViewModel.clear()
                selectionModel.deselect()
            }
        }
    }

    func upload() async {
        guard selectionModel.count > 0 else { print("No videos selected."); return }
        for video in selectionModel {
            Task {
                await Uploader.shared.upload(for: video, to: "api/upload")
            }
        }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
    }
}
