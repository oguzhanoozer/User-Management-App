//
//  Layout.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct Layout {
    static let cornerRadiusSmall: CGFloat = 8
    static let cornerRadiusMedium: CGFloat = 12
    static let cornerRadiusLarge: CGFloat = 16
    static let cornerRadiusXLarge: CGFloat = 20
    

    static let cardCornerRadius: CGFloat = 16
    static let cardMinHeight: CGFloat = 80
    static let cardElevation: CGFloat = 2
    

    static let avatarSmall: CGFloat = 32
    static let avatarMedium: CGFloat = 48
    static let avatarLarge: CGFloat = 60
    static let avatarXLarge: CGFloat = 100
    

    static let buttonHeight: CGFloat = 44
    static let buttonHeightSmall: CGFloat = 36
    static let buttonHeightLarge: CGFloat = 52
    static let buttonCornerRadius: CGFloat = 12
    

    static let iconSmall: CGFloat = 16
    static let iconMedium: CGFloat = 20
    static let iconLarge: CGFloat = 24
    static let iconXLarge: CGFloat = 32
    

    static let textFieldHeight: CGFloat = 48
    static let textFieldCornerRadius: CGFloat = 8
    static let pickerHeight: CGFloat = 40
    

    static let navigationBarHeight: CGFloat = 44
    static let tabBarHeight: CGFloat = 80
    static let searchBarHeight: CGFloat = 40
    

    static let listRowMinHeight: CGFloat = 60
    static let refreshControlOffset: CGFloat = -60
    

    static let maxContentWidth: CGFloat = 400
    static let minTapTargetSize: CGFloat = 44
}


struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    static let none = ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)
    static let small = ShadowStyle(color: .shadowColor, radius: 2, x: 0, y: 1)
    static let medium = ShadowStyle(color: .shadowColor, radius: 4, x: 0, y: 2)
    static let large = ShadowStyle(color: .shadowColor, radius: 8, x: 0, y: 4)
    

    static let card = ShadowStyle(color: .shadowColor, radius: 4, x: 0, y: 2)
    static let cardHover = ShadowStyle(color: .shadowColor, radius: 6, x: 0, y: 3)
}


struct BorderStyle {
    let color: Color
    let width: CGFloat
    
    static let none = BorderStyle(color: .clear, width: 0)
    static let thin = BorderStyle(color: .borderColor, width: 0.5)
    static let medium = BorderStyle(color: .borderColor, width: 1)
    static let thick = BorderStyle(color: .borderColor, width: 2)
    

    static let textField = BorderStyle(color: .borderColor, width: 1)
    static let card = BorderStyle(color: .borderColor.opacity(0.1), width: 0.5)
}

extension View {
    func cardCornerRadius() -> some View {
        self.cornerRadius(Layout.cardCornerRadius)
    }
    
    func buttonCornerRadius() -> some View {
        self.cornerRadius(Layout.buttonCornerRadius)
    }
    
    func customCornerRadius(_ radius: CGFloat) -> some View {
        self.cornerRadius(radius)
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
    
    func customShadow(_ style: ShadowStyle) -> some View {
        self.shadow(
            color: style.color,
            radius: style.radius,
            x: style.x,
            y: style.y
        )
    }
    

    func customBorder(_ style: BorderStyle) -> some View {
        self.overlay(
            Rectangle()
                .stroke(style.color, lineWidth: style.width)
        )
    }
    
    func textFieldBorder() -> some View {
        self.customBorder(.textField)
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
    

    func minTapTarget() -> some View {
        self.frame(minWidth: Layout.minTapTargetSize, minHeight: Layout.minTapTargetSize)
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
            .customBorder(.medium)
            .foregroundColor(.textPrimary)
    }
}