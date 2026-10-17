//
//  BookNestApp.swift
//  BookNest
//
import SwiftUI
import SwiftData

@main
struct BookNestApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
   
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [User.self, Book.self, Loan.self, BookCategory.self])
    }
}

