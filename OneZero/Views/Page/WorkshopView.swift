//
//  WorkshopView.swift
//  OneZero
//
//  Created by Fish on 24/8/2024.
//

import SwiftUI
import AVKit
import Kingfisher
import SwiftUIPager

struct VideoCoverView: View {
    let url: URL?
    @State var loading: Bool = true
    @State var videoCover: Image? = nil
    
    var body: some View {
        HStack {
            if loading {
                ProgressView()
            } else if videoCover != nil {
                videoCover?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 400, height: 400)
            } else {
                Image("error-img")
            }
        }
        .frame(width: 400, height: 400)
        .aspectRatio(contentMode: .fit)
        .task {
            await thumbnail()
        }
    }
    
    func thumbnail() async {
        await MainActor.run {
            loading = true
        }
        guard let url = url else {
            await MainActor.run {
                loading = false
            }
            return
        }
        print("loading thumnail for \(url.absoluteString)")
        let asset = AVURLAsset(url: url, options: nil)
        let img_gen = AVAssetImageGenerator(asset: asset)
        img_gen.appliesPreferredTrackTransform = true
        DispatchQueue.global().async {
            do {

                let cgImg = try img_gen.copyCGImage(at: CMTime(seconds: 1.0, preferredTimescale: 60), actualTime: nil)
                DispatchQueue.main.async {
                    self.videoCover = Image(cgImg, scale: 1.0, orientation: .up, label: Text(""))
                    print("Fucking success to load thumbnail of \(url.absoluteString)")
                }
            } catch {
                print("Some error occurs while generating thumbnail of url \(url): \(error)")
            }
            DispatchQueue.main.async {
                self.loading = false
            }
        }
    }
}

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

struct WorkshopThumView: View {
    var work: WorkshopItem
    @State var coverURL: URL?
    @State var isVideo: Bool = false
    @State var hovering: Bool = false
    
    init(work: WorkshopItem) {
        self.work = work
    }
    
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
                print("\(coverURL?.absoluteString) is video.")
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
