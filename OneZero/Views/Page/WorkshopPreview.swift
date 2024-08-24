//
//  WorkshopPreview.swift
//  OneZero
//
//  Created by Fish on 24/8/2024.
//

import SwiftUI
import AVKit
import SwiftUIPager
import Kingfisher

struct WorkshopPreview: View {
    let work: WorkshopItem
    @StateObject var page: Page = .first()
    var body: some View {
        ScrollView {
            Text(work.title)
                .font(.title)
            Text(work.description)
                .font(.title3)
            HStack {
                Text("Category: ")
                Text(work.category.localizedString)
            }
            HStack(alignment: .center) {
                VStack {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 36)
                        .opacity( page.index == 0 ? 0.5 : 1.0 )
                }
                .padding()
                .frame(height: 200)
                .onTapGesture {
                    if page.index != 0 {
                        withAnimation {
                            page.update(.previous)
                        }
                    }
                    
                }

                LazyHStack {
                    Pager(page: page, data: work.mediaItems, id: \.self) { media in
                        if MediaFactory.mediaType(media.url) == .movie {
                            VideoPlayer(player: AVPlayer(url: media.url))
                                .frame(width: 300, height: 300)
                                .aspectRatio(contentMode: .fit)
                        } else if MediaFactory.mediaType(media.url) == .image {
                            KFImage(media.url)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 300)
                        }
                    }
                    .itemSpacing(10)
                    .padding(20)
                    .disableDragging()
                    .frame(width: 400, height: 400)
                    .aspectRatio(contentMode: .fit)
                }
                .frame(width: 490, height: 350)
                
                VStack {
                    Image(systemName: "chevron.forward")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 36)
                        .opacity( page.index+1 == work.mediaItems.count ? 0.5 : 1.0 )
                }
                .padding(10)
                .frame(height: 200)
                .onTapGesture {
                    if page.index+1 < work.mediaItems.count {
                        withAnimation {
                            page.update(.next)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: 600, maxHeight: 400)
    }
}
