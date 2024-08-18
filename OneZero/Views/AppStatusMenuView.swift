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
        Button("Upload videos from clipboard") {
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
    
    /**
     Upload from Clipboard(or, Pasteboard in apple style?).
     Normally, upload the most recently copied file to server.
     At the time of writing these words, only supports video file like mp4/avi/mkv/mov.
     */
    func uploadByPasteboard() async {
        if let files = NSPasteboard.general.propertyList(forType: NSPasteboard.PasteboardType("NSFilenamesPboardType")) as? [String] {
//            print(files)
            let filesToUpload = files.filter{
                supportedFormats.contains(($0 as NSString).pathExtension)
            }
            await Uploader.shared.uploadVideos(filesToUpload, to: "api/upload")
        }
    }
}

struct AppStatusMenuView_Previews: PreviewProvider {
    static var previews: some View {
        AppStatusMenuView()
    }
}
