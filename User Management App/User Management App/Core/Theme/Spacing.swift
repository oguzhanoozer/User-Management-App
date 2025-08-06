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
    static let cardPadding: CGFloat = 16
    
    static let buttonHorizontal: CGFloat = 16
    static let buttonVertical: CGFloat = 8
        
}

extension View {
    func screenPadding() -> some View {
        self.padding(.horizontal, Spacing.screenHorizontal)
    }
    
    func cardPadding() -> some View {
        self.padding(Spacing.cardPadding)
    }
    
    func buttonPadding() -> some View {
        self.padding(.horizontal, Spacing.buttonHorizontal)
            .padding(.vertical, Spacing.buttonVertical)
    }
    
    func sectionSpacing() -> some View {
        self.padding(.bottom, Spacing.xxl)
    }
    

    
}
