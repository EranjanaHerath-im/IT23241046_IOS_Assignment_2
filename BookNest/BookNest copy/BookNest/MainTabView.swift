//
//  MainTabView.swift
//  BookNest
//
import SwiftUI

struct MainTabView: View {
    let user: User
   
    var body: some View {
        TabView {
            BookListView(user: user)
                .tabItem {
                    Label("Books", systemImage: "book")
                }
           
            if user.role == .librarian {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.bar")
                    }
            }
           
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
