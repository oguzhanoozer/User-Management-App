//
//  Layout.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct Layout {
    // MARK: - Corner Radius
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    
    // MARK: - Card
    static let cardCornerRadius: CGFloat = 16
    
    // MARK: - Avatar Sizes
    static let avatarMedium: CGFloat = 48
    static let avatarLarge: CGFloat = 60
    static let avatarXLarge: CGFloat = 100
    
    // MARK: - Button
    static let buttonHeight: CGFloat = 44
    static let buttonCornerRadius: CGFloat = 12
    
    // MARK: - Icon Sizes
    static let iconMedium: CGFloat = 20
    static let iconLarge: CGFloat = 24
    static let iconXLarge: CGFloat = 32
    
    // MARK: - Text Field
    static let textFieldHeight: CGFloat = 48
    static let textFieldCornerRadius: CGFloat = 8
    
    // MARK: - List
    static let listRowMinHeight: CGFloat = 60
    
    // MARK: - Touch Target
    static let minTapTargetSize: CGFloat = 44
}


struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    // Only keeping used shadow styles
    static let card = ShadowStyle(color: .shadowColor, radius: 4, x: 0, y: 2)
}

extension View {
    func cardCornerRadius() -> some View {
        self.cornerRadius(Layout.cardCornerRadius)
    }
    
    func buttonCornerRadius() -> some View {
        self.cornerRadius(Layout.buttonCornerRadius)
    }
    
    func cardShadow() -> some View {
        let shadow = ShadowStyle.card
        return self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
    
    func avatarSize(_ size: CGFloat = Layout.avatarLarge) -> some View {
        self.frame(width: size, height: size)
    }
    
    func buttonHeight(_ height: CGFloat = Layout.buttonHeight) -> some View {
        self.frame(height: height)
    }
    
    func iconSize(_ size: CGFloat = Layout.iconMedium) -> some View {
        self.frame(width: size, height: size)
    }
}

struct LayoutComponents {
    static func cardContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .cardPadding()
            .background(Color.backgroundSecondary)
            .cardCornerRadius()
            .cardShadow()
    }
    

    static func userCardContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .cardPadding()
            .background(Color.cardBackground)
            .cardCornerRadius()
            .cardShadow()
    }
    

    static func primaryButton<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .buttonPadding()
            .buttonHeight()
            .background(Color.primaryBlue)
            .buttonCornerRadius()
            .foregroundColor(.textOnPrimary)
    }
    
    static func secondaryButton<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .buttonPadding()
            .buttonHeight()
            .background(Color.backgroundSecondary)
            .buttonCornerRadius()
            .overlay(
                Rectangle()
                    .stroke(Color.borderColor, lineWidth: 1)
            )
            .foregroundColor(.textPrimary)
    }
}