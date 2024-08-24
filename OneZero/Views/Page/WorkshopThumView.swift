//
//  WorkshopThumbView.swift
//  OneZero
//
//  Created by Fish on 24/8/2024.
//

import SwiftUI
import Kingfisher

struct WorkshopThumView: View {
    var work: WorkshopItem
    @State var coverURL: URL?
    @State var isVideo: Bool = false
    @State var hovering: Bool = false
    
    var body: some View {
        VStack {
            if coverURL != nil && !isVideo {
                KFImage(coverURL)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 400)
            } else if isVideo {
                VideoCoverView(url: coverURL)
            } else {
                Image("error-img")
            }

            Text(work.description)
                .font(.title3)
        }
        .frame(width: 450, height: 500)
        .onAppear {
            coverURL = randomCover()
            if MediaFactory.mediaType(coverURL) == .movie {
                print("\(coverURL?.absoluteString ?? "NULL") is video.")
                isVideo = true
            } else {
                isVideo = false
            }
        }
        .popover(isPresented: $hovering, arrowEdge: .trailing) {
            WorkshopPreview(work: work)
                .padding()
                .frame(width: 600, height: 400)
        }
        .onTapGesture {
            hovering.toggle()
        }
        .padding()
    }
    
    func randomCover() -> URL? {
        return work.mediaItems.randomElement()?.url
    }
}
