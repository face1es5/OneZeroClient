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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(theme == .system ? .none : (theme == .light ? .light : .dark))
        }
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
