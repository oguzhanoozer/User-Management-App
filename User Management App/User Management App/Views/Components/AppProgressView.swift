//
//  ProgressViewComponents.swift
//  User Management App
//
//  Created by oguzhan on 6.08.2025.
//

import SwiftUI


struct AppProgressView: View {
    let style: ProgressStyle
    
    enum ProgressStyle {
        case primary(scale: CGFloat = 1.5)
        case secondary(scale: CGFloat = 0.8)
        case button(scale: CGFloat = 0.8)
        case custom(scale: CGFloat, tint: Color)
        
        var scale: CGFloat {
            switch self {
            case .primary(let scale), .secondary(let scale), .button(let scale), .custom(let scale, _):
                return scale
            }
        }
        
        var tint: Color {
            switch self {
            case .primary, .secondary:
                return .primaryBlue
            case .button:
                return .white
            case .custom(_, let tint):
                return tint
            }
        }
    }
    
    var body: some View {
        ProgressView()
            .scaleEffect(style.scale)
            .progressViewStyle(CircularProgressViewStyle(tint: style.tint))
    }
}


extension AppProgressView {
    static var primary: AppProgressView {
        AppProgressView(style: .primary())
    }
    
    static var secondary: AppProgressView {
        AppProgressView(style: .secondary())
    }
    
    static var button: AppProgressView {
        AppProgressView(style: .button())
    }
    
    static func primary(scale: CGFloat) -> AppProgressView {
        AppProgressView(style: .primary(scale: scale))
    }
    
    static func secondary(scale: CGFloat) -> AppProgressView {
        AppProgressView(style: .secondary(scale: scale))
    }
    
    static func button(scale: CGFloat) -> AppProgressView {
        AppProgressView(style: .button(scale: scale))
    }
    
    static func custom(scale: CGFloat, tint: Color) -> AppProgressView {
        AppProgressView(style: .custom(scale: scale, tint: tint))
    }
}
