//
//  Spacing.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    
    static let screenHorizontal: CGFloat = 16
    static let screenVertical: CGFloat = 16
    static let safeAreaBottom: CGFloat = 20
    static let safeAreaTop: CGFloat = 8
    
    static let cardPadding: CGFloat = 16
    static let cardSpacing: CGFloat = 12
    static let cardInternalSpacing: CGFloat = 12
    
    static let buttonHorizontal: CGFloat = 16
    static let buttonVertical: CGFloat = 8
    static let buttonSpacing: CGFloat = 12
    
    static let listItemSpacing: CGFloat = 8
    static let listSectionSpacing: CGFloat = 24
    static let listHeaderSpacing: CGFloat = 12
    
    static let formFieldSpacing: CGFloat = 16
    static let formSectionSpacing: CGFloat = 24
    static let formLabelSpacing: CGFloat = 8
    
    static let navigationPadding: CGFloat = 16
    static let tabBarPadding: CGFloat = 12
    
    static let avatarSpacing: CGFloat = 12
    static let iconSpacing: CGFloat = 8
}

extension View {
    func screenPadding() -> some View {
        self.padding(.horizontal, Spacing.screenHorizontal)
            .padding(.vertical, Spacing.screenVertical)
    }
    
    func cardPadding() -> some View {
        self.padding(Spacing.cardPadding)
    }
    
    func buttonPadding() -> some View {
        self.padding(.horizontal, Spacing.buttonHorizontal)
            .padding(.vertical, Spacing.buttonVertical)
    }
    
    func formFieldPadding() -> some View {
        self.padding(.vertical, Spacing.formLabelSpacing)
    }
    

    func cardSpacing() -> some View {
        self.padding(.bottom, Spacing.cardSpacing)
    }
    
    func sectionSpacing() -> some View {
        self.padding(.bottom, Spacing.listSectionSpacing)
    }
    

    func customSpacing(_ value: CGFloat) -> some View {
        self.padding(.bottom, value)
    }
    
    func customHorizontalPadding(_ value: CGFloat) -> some View {
        self.padding(.horizontal, value)
    }
    
    func customVerticalPadding(_ value: CGFloat) -> some View {
        self.padding(.vertical, value)
    }
}

struct CustomSpacer {
    static func height(_ value: CGFloat) -> some View {
        Spacer()
            .frame(height: value)
    }
    
    static func width(_ value: CGFloat) -> some View {
        Spacer()
            .frame(width: value)
    }
    

    static var small: some View { height(Spacing.sm) }
    static var medium: some View { height(Spacing.md) }
    static var large: some View { height(Spacing.lg) }
    static var extraLarge: some View { height(Spacing.xl) }
}