//
//  Settings.swift
//  OneZero
//
//  Created by Fish on 13/8/2024.
//

import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: Self { self }
}

struct GeneralSettingsView: View {
    @AppStorage("theme") var theme: AppTheme = .system
    @AppStorage("api") var baseURL: String = ""
    @AppStorage("cloudURL") var cloudURL: String = ""
    var body: some View {
        Form {
            Picker("Appearance:", selection: $theme) {
                Text("System").tag(AppTheme.system)
                Text("Light").tag(AppTheme.light)
                Text("Dark").tag(AppTheme.dark)
            }
            .frame(maxWidth: 200)
            TextField("Server:", text: $baseURL)
            TextField("Cloud Storage:", text: $cloudURL)
        }
        .padding()
        .frame(width: 350, height: 100)
    }
}

struct AdvancedSettingsView: View {
    @AppStorage("useProxy") var useDebugProxy: Bool = false
    @AppStorage("api") var baseURL: String = ""

    var body: some View {
        Form {
            Toggle("Use debug proxy", isOn: $useDebugProxy)
                .onChange(of: useDebugProxy) { newValue in
                    if newValue {
                        baseURL = "http://proxyman.debug:3000"
                    }
                }
        }
        .padding()
        .frame(width: 350, height: 50)
    }
}

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
                .badge(2)
            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "gearshape.2")
                }
                .badge(2)
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
