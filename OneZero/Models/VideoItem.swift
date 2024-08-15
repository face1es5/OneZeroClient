//
//  VideoItem.swift
//  OneZero
//
//  Created by Fish on 14/8/2024.
//

import Foundation
import SwiftUI
import AVFoundation

class VideoItem: Identifiable, Hashable, ObservableObject {
    let id = UUID()
    let url: URL
    let name: String
    var thumbnail: Image? = nil
    @Published var isSelected: Bool = false
    @Published var loadingThumb: Bool = true
    @Published var uploading: Bool = false

    init(from url: URL) {
        self.url = url
        name = url.lastPathComponent
    }

    init(from url: String) {
        self.url = URL(fileURLWithPath: url)
        name = self.url.lastPathComponent
    }

    static func == (lhs: VideoItem, rhs: VideoItem) -> Bool {
        return lhs.id == rhs.id || lhs.url.absoluteString == rhs.url.absoluteString
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteString)
    }
    
    func genThumbnail() {
        self.loadingThumb = true
        print("generating image thumbnail from \(self.url)")
        let asset = AVURLAsset(url: self.url, options: nil)
        let img_gen = AVAssetImageGenerator(asset: asset)
        img_gen.appliesPreferredTrackTransform = true
        DispatchQueue.global().async {
            defer {
                DispatchQueue.main.async {
                    self.loadingThumb = false
                }
            }
            do {
                let cgImg = try img_gen.copyCGImage(at: CMTime(seconds: 1.0, preferredTimescale: 60), actualTime: nil)
                DispatchQueue.main.async {
                    self.thumbnail = Image(cgImg, scale: 1.0, orientation: .up, label: Text(self.name))
                }
            } catch {
                print("Some error occurs while generating thumbnail of url \(self.url): \(error)")
            }
        }
    }
}
