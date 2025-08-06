//
//  Typography.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

extension Font {
    static let largeTitle = Font.system(size: 32, weight: .bold, design: .default)
    
    static let headline = Font.system(size: 18, weight: .semibold, design: .default)
    static let subheadline = Font.system(size: 16, weight: .medium, design: .default)
    
    static let body = Font.system(size: 14, weight: .regular, design: .default)
    
    static let caption1 = Font.system(size: 12, weight: .medium, design: .default)
    
    static let navigationTitle = Font.system(size: 20, weight: .bold, design: .default)
    static let cardTitle = Font.system(size: 16, weight: .semibold, design: .default)
    static let cardSubtitle = Font.system(size: 14, weight: .regular, design: .default)
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
    
    
    func captionStyle() -> some View {
        self
            .font(.caption1)
            .foregroundColor(.textSecondary)
    }
    
}
