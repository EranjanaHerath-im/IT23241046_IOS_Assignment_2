//
//  SettingsView.swift
//  BookNest
//
import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) private var colorScheme
   
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .tint(AppTheme.primary)
                   
                    HStack {
                        Text("Current Mode")
                        Spacer()
                        Text(isDarkMode ? "Dark" : "Light")
                            .foregroundStyle(.secondary)
                    }
                }
               
                Section("About") {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("BookNest")
                            .foregroundStyle(.secondary)
                    }
                   
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    SettingsView()
}

