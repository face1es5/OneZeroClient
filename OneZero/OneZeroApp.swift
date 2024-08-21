//
//  OneZeroApp.swift
//  OneZero
//
//  Created by Fish on 8/8/2024.
//

import SwiftUI

@main
struct OneZeroApp: App {
    @AppStorage("theme") var theme: AppTheme = .system
    @StateObject var mediaViewModel: MediaViewModel = MediaViewModel()
    @StateObject var selectionModel: SelectionModel<MediaItem> = SelectionModel<MediaItem>()
    @StateObject var appViewModel: AppViewModel = AppViewModel()
    @StateObject var uploadManger: UploadManager = UploadManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(theme == .system ? .none : (theme == .light ? .light : .dark))
                .environment(\.locale, .init(identifier: "zh-Hans"))
                .environmentObject(mediaViewModel)
                .environmentObject(selectionModel)
                .environmentObject(appViewModel)
                .environmentObject(uploadManger)
        }
        #if os(macOS)
            MenuBarExtra("App Menu Bar Extra", systemImage: "camera.aperture") {
                AppStatusMenuView()
            }
            Settings {
                SettingsView()
            }
        #endif
    }
}
