//
//  VideoItem.swift
//  OneZero
//
//  Created by Fish on 14/8/2024.
//

import Foundation
import SwiftUI
import AVFoundation

/**
 Class that hold some meta info for a specific video item.
 */
class VideoAsset: ObservableObject {
    @Published var size: String = "loading..."
    @Published var duration: String = "loading..."
    @Published var resolution: String = "loading..."
    @Published var creationDate: String = "loading..."
    
    private func getSize(_ url: URL) -> String {
        if url.scheme != "file" { return "Unknown" }
        guard
            let attr = try? FileManager.default.attributesOfItem(atPath: url.path),
            let filesz = attr[.size] as? Int64
        else {
            return "Invalid"
        }
        return filesz.formattedFileSize()
    }
    
    private func getDuration(_ asset: AVAsset) async -> String {
        guard let duration = try? await asset.load(.duration)
        else {
            return "not available"
        }
        return String(format: "%.2f", CMTimeGetSeconds(duration))
    }
    
    private func getResolution(_ asset: AVAsset) async -> String {
        guard
            let track = try? await asset.loadTracks(withMediaType: .video).first,
            let sz = try? await track.load(.naturalSize)
        else { return "not available" }
        return "\(Int(sz.width)) x \(Int(sz.height))"
    }
    
    private func getCreationDate(_ asset: AVAsset) async -> String {
        guard
            let meta = try? await asset.load(.commonMetadata).first(where: { $0.commonKey?.rawValue == "creationDate" }),
            let date = try? await meta.load(.value) as? Date
        else{
            return "not available"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "y 年 MMM 月 d 日 E HH:mm"
        return formatter.string(from: date)
    }
    
    /**
     Generate meta info of resource specified by url asynchronously.
     */
    init(from url: URL) {
        Task {
            let asset = AVAsset(url: url)
            size = getSize(url)
            duration = await getDuration(asset)
            resolution = await getResolution(asset)
            creationDate = await getCreationDate(asset)
        }
    }
}

class VideoItem: Identifiable, Hashable, ObservableObject {
    let id = UUID()
    let url: URL
    let name: String
    var thumbnail: Image? = nil
    @ObservedObject var meta: VideoAsset
    @Published var isSelected: Bool = false
    @Published var loadingThumb: Bool = true
    @Published var uploading: Bool = false
    @Published var description: String = ""
    @Published var title: String = ""

    /**
     Init video item from URL struct.
     */
    init(from url: URL) {
        self.url = url
        name = url.lastPathComponent
        meta = VideoAsset(from: url)
    }

    /**
     Init video item from url string(local or remote).
     */
    init(from urlString: String) {
        url = URL(fileURLWithPath: urlString)
        name = url.lastPathComponent
        meta = VideoAsset(from: url)
    }
    
    static func == (lhs: VideoItem, rhs: VideoItem) -> Bool {
        return lhs.id == rhs.id || lhs.url.absoluteString == rhs.url.absoluteString
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteString)
    }
    
    /**
     Generate thumbnail for a video asynchronously(but change observed state in main thread).
     */
    func genThumbnail() async {
        DispatchQueue.main.async {  // Force updating in main thread as it's a state related to UI in case task started in background.
            self.loadingThumb = true
        }
//        print("generating image for \(self.name) thumbnail from \(self.url.urlDecode())")
        let asset = AVURLAsset(url: self.url, options: nil)
        let img_gen = AVAssetImageGenerator(asset: asset)
        img_gen.appliesPreferredTrackTransform = true
        DispatchQueue.global().async {
            do {
                defer {
                    DispatchQueue.main.async {
//                        print("loading thumbnail finished.")
//                        print(self.thumbnail == nil)
                        self.loadingThumb = false
                    }
                }
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
