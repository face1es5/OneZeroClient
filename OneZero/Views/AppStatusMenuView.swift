//
//  AppStatusMenuView.swift
//  OneZero
//
//  Created by Fish on 15/8/2024.
//

import SwiftUI

struct AppStatusMenuView: View {
    private let supportedFormats = ["mp4", "avi", "mkv", "mov"]
    var body: some View {
        Button("Upload media from clipboard") {
            Task {
                await uploadByPasteboard()
            }
        }
        .keyboardShortcut("v")
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }.keyboardShortcut("q")
    }
    
    /// Upload from Clipboard(or, Pasteboard in apple style?).
    /// Normally, upload the most recently copied file to server.
    /// At the time of writing these words, only supports video file like mp4/avi/mkv/mov.
    ///
    /// Now, support any file(maybe, mainly for video&image).
    func uploadByPasteboard() async {
        if let files = NSPasteboard.general.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] {
            let filesToUpload = files.filter{
                supportedFormats.contains(($0 as NSString).pathExtension)
            }
            await Uploader.shared.uploadSomeMedia(filesToUpload, to: "api/upload")
        }
    }
}

struct AppStatusMenuView_Previews: PreviewProvider {
    static var previews: some View {
        AppStatusMenuView()
    }
}
