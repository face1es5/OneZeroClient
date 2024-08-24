//
//  CoverView.swift
//  OneZero
//
//  Created by Fish on 24/8/2024.
//

import SwiftUI
import AVKit

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
//        print("loading thumnail for \(url.absoluteString)")
        let asset = AVURLAsset(url: url, options: nil)
        let img_gen = AVAssetImageGenerator(asset: asset)
        img_gen.appliesPreferredTrackTransform = true
        DispatchQueue.global().async {
            do {

                let cgImg = try img_gen.copyCGImage(at: CMTime(seconds: 1.0, preferredTimescale: 60), actualTime: nil)
                DispatchQueue.main.async {
                    self.videoCover = Image(cgImg, scale: 1.0, orientation: .up, label: Text(""))
//                    print("Fucking success to load thumbnail of \(url.absoluteString)")
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

