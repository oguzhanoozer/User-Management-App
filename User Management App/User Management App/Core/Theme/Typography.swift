//
//  Typography.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

extension Font {
    static let largeTitle = Font.system(size: 32, weight: .bold, design: .default)
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)
    static let title2 = Font.system(size: 22, weight: .bold, design: .default)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
    
    static let headline = Font.system(size: 18, weight: .semibold, design: .default)
    static let subheadline = Font.system(size: 16, weight: .medium, design: .default)
    
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    static let body = Font.system(size: 14, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)
    
    static let caption1 = Font.system(size: 12, weight: .medium, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    
    static let navigationTitle = Font.system(size: 20, weight: .bold, design: .default)
    static let cardTitle = Font.system(size: 16, weight: .semibold, design: .default)
    static let cardSubtitle = Font.system(size: 14, weight: .regular, design: .default)
    static let buttonText = Font.system(size: 14, weight: .medium, design: .default)
    static let tagText = Font.system(size: 12, weight: .medium, design: .default)
}

struct Typography {
    struct UserCard {
        static let name = Font.cardTitle
        static let email = Font.cardSubtitle
        static let role = Font.caption1
        static let tag = Font.tagText
    }
    
    struct Navigation {
        static let title = Font.navigationTitle
        static let backButton = Font.buttonText
        static let tabItem = Font.caption1
    }
    
    struct Form {
        static let label = Font.subheadline
        static let input = Font.body
        static let helper = Font.caption2
        static let error = Font.caption1
    }
    
    struct Button {
        static let primary = Font.buttonText
        static let secondary = Font.buttonText
        static let small = Font.caption1
    }
    
    struct Detail {
        static let sectionHeader = Font.headline
        static let sectionContent = Font.body
        static let experience = Font.tagText
        static let focus = Font.bodySmall
    }
}


extension View {
    func primaryTitleStyle() -> some View {
        self
            .font(.navigationTitle)
            .foregroundColor(.textPrimary)
    }
    
    func cardTitleStyle() -> some View {
        self
            .font(.cardTitle)
            .foregroundColor(.textPrimary)
    }
    
    func cardSubtitleStyle() -> some View {
        self
            .font(.cardSubtitle)
            .foregroundColor(.textSecondary)
    }
    
    func sectionHeaderStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.primaryBlue)
    }
    
    func bodyTextStyle() -> some View {
        self
            .font(.body)
            .foregroundColor(.textPrimary)
    }
    
    func captionStyle() -> some View {
        self
            .font(.caption1)
            .foregroundColor(.textSecondary)
    }
    
    func tagStyle() -> some View {
        self
            .font(.tagText)
            .foregroundColor(.textOnPrimary)
    }
}