//
//  Colors.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

extension Color {
    static let primaryBlue = Color(hex: "2260FF")
    static let primaryBlueDark = Color(hex: "3367D6")
    
    static let backgroundPrimary = Color(hex: "F8F9FA")
    static let backgroundSecondary = Color(hex: "FFFFFF")
    static let cardBackground = Color(hex: "CAD6FF")
    
    static let textPrimary = Color(hex: "1A1A1A")
    static let textSecondary = Color(hex: "6B7280")
    static let textTertiary = Color(hex: "9CA3AF")
    static let textOnPrimary = Color.white
    
    static let borderColor = Color(hex: "E5E7EB")
    static let shadowColor = Color.black.opacity(0.08)
    static let separatorColor = Color(hex: "F3F4F6")
    
    static let successGreen = Color(hex: "10B981")
    static let warningOrange = Color(hex: "F59E0B")
    static let errorRed = Color(hex: "EF4444")
    static let infoBlue = Color(hex: "3B82F6")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Note: ThemeColors struct removed as it was not being used in the codebase
