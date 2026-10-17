//
//  Theme.swift
//  BookNest
//
import SwiftUI

struct AppTheme {
    static let primary = Color(red: 0.15, green: 0.45, blue: 0.48)      // Deep teal
    static let accent = Color(red: 0.85, green: 0.55, blue: 0.25)       // Warm amber
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
   
    static let cornerRadius: CGFloat = 16
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
