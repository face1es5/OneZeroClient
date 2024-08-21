//
//  MediaItem.swift
//  OneZero
//
//  Created by Fish on 21/8/2024.
//

import Foundation
import SwiftUI
import AVFoundation
import QuickLookThumbnailing

/**
 Class that hold some meta info for a specific media item.
 */
class MediaAsset: ObservableObject {
    var size: Int64 = .zero
    @Published var formattedSize: String = "loading..."
    @Published var duration: String = "loading..."
    @Published var resolution: String = "loading..."
    @Published var creationDate: String = "loading..."
    
    private func getFormattedSize(_ url: URL) -> String {
        if url.scheme != "file" { return "Unknown" }
        guard
            let attr = try? FileManager.default.attributesOfItem(atPath: url.path),
            let filesz = attr[.size] as? Int64
        else {
            return "Invalid"
        }
        size = filesz
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
            formattedSize = getFormattedSize(url)
            duration = await getDuration(asset)
            resolution = await getResolution(asset)
            creationDate = await getCreationDate(asset)
        }
    }
}

/// Base class for Video&Image.
///
class MediaItem: Identifiable, Hashable, ObservableObject, Equatable {
    let id = UUID()
    let url: URL
    let name: String
    var thumbnail: Image? = nil
    var errorHint: String?
    @ObservedObject var meta: MediaAsset
    @Published var isSelected: Bool = false
    @Published var loadingThumb: Bool = true
    @Published var uploading: Bool = false
    @Published var failedToUploading: Bool = false
    @Published var description: String = ""
    @Published var title: String = ""
    
    /**
     Init media item from URL struct.
     */
    init(from url: URL) {
        self.url = url
        name = url.lastPathComponent
        meta = MediaAsset(from: url)
    }

    /**
     Init media item from url string(local or remote).
     */
    init(from urlString: String) {
        url = URL(fileURLWithPath: urlString)
        name = url.lastPathComponent
        meta = MediaAsset(from: url)
    }
    
    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool {
        return lhs.id == rhs.id || lhs.url.absoluteString == rhs.url.absoluteString
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteString)
    }
    
    func genThumbnail() async {
        fatalError("You must implement genThumbnail in sub class.")
    }
    
}

/// Image item.
///
class ImageItem: MediaItem {
    override func genThumbnail() async {
        DispatchQueue.main.async {
            self.loadingThumb = true
        }
        defer {
            DispatchQueue.main.async {
                self.loadingThumb = false
            }
        }
        guard let nsimg = NSImage(contentsOf: url) else {
            print("Can't generating thumnail for image \(name) of url: \(url)")
            return
        }
        thumbnail = Image(nsImage: nsimg)
    }
}

/// Video item.
///
class VideoItem: MediaItem {
    /**
     Generate thumbnail for a video asynchronously(but change observed state in main thread).
     */
    override func genThumbnail() async {
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


/// Factory to create media item based on file extension.
///
class MediaFactory {
    static func mediaType(_ url: URL) -> UTType {
        guard let type = UTType(filenameExtension: url.pathExtension) else { return .data }
        if type.conforms(to: .movie) {
            return .movie
        } else if type.conforms(to: .image) {
            return .image
        }
        return .data
    }
    static func mimeType(_ ext: String) -> String {
        guard
            let utType = UTType(filenameExtension: ext),
            let mime = utType.preferredMIMEType
        else { return "application/octet-stream" }
        return mime
    }
    static func mimeType(_ url: URL) -> String {
        return mimeType(url.pathExtension)
    }
    static func createMedia(from path: String) -> MediaItem {
        return createMedia(from: URL(fileURLWithPath: path))
    }
    static func createMedia(from url: URL) -> MediaItem {
        switch (mediaType(url)) {
        case .movie:
            return VideoItem(from: url)
        case .image:
            return ImageItem(from: url)
        default:
            return MediaItem(from: url)
        }
    }
}
