//
//  Theme.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI


class ThemeManager: ObservableObject {
    @Published var currentColorScheme: ColorScheme = .light
    
    static let shared = ThemeManager()
    
    private init() {}
    
    // ThemeColors struct removed - using direct Color extensions instead
}

struct AppTheme {
    static var spacing = Spacing.self
    static var layout = Layout.self
    static var typography = Typography.self
    

    struct UserCard {
        static let backgroundColor = Color.cardBackground
        static let cornerRadius = Layout.cardCornerRadius
        static let padding = Spacing.cardPadding
        static let avatarSize = Layout.avatarLarge
        static let shadow = ShadowStyle.card
    }
    
    struct Navigation {
        static let titleColor = Color.primaryBlue
        static let backgroundColor = Color.backgroundSecondary
        static let tintColor = Color.primaryBlue
    }
    
    struct Button {
        struct Primary {
            static let backgroundColor = Color.primaryBlue
            static let foregroundColor = Color.textOnPrimary
            static let cornerRadius = Layout.buttonCornerRadius
            static let height = Layout.buttonHeight
            static let font = Typography.Button.primary
        }
        
        struct Secondary {
            static let backgroundColor = Color.backgroundSecondary
            static let foregroundColor = Color.textPrimary
            static let borderColor = Color.borderColor
            static let cornerRadius = Layout.buttonCornerRadius
            static let height = Layout.buttonHeight
            static let font = Typography.Button.secondary
        }
        
        struct Tag {
            static let backgroundColor = Color.primaryBlue
            static let foregroundColor = Color.textOnPrimary
            static let cornerRadius = Layout.cornerRadiusSmall
            static let font = Typography.Button.small
        }
    }
    
    struct List {
        static let backgroundColor = Color.backgroundPrimary
        static let separatorColor = Color.separatorColor
        static let rowMinHeight = Layout.listRowMinHeight
    }
    
    struct Form {
        static let backgroundColor = Color.backgroundPrimary
        static let fieldBackgroundColor = Color.backgroundSecondary
        static let fieldBorderColor = Color.borderColor
        static let fieldCornerRadius = Layout.textFieldCornerRadius
        static let fieldHeight = Layout.textFieldHeight
        static let errorColor = Color.errorRed
        static let labelColor = Color.textSecondary
    }
}


struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var theme: ThemeManager {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}


struct ThemeModifier: ViewModifier {
    @StateObject private var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .environmentObject(themeManager)
            .environment(\.theme, themeManager)
            .preferredColorScheme(.light) // Force light mode for now
    }
}

extension View {
    func applyTheme() -> some View {
        self.modifier(ThemeModifier())
    }
}


struct ThemePreview {
    static func withTheme<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .applyTheme()
            .background(Color.backgroundPrimary)
    }
}


// Note: Color extension simplified - using direct Color.primaryBlue etc. instead of theme wrapper

extension Font {
    static var theme: Typography.Type { Typography.self }
}

#if DEBUG
struct ThemeDebugView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Colors
                VStack(alignment: .leading, spacing: 8) {
                    Text("Colors").font(.title2).bold()
                    
                    HStack(spacing: 8) {
                        colorSwatch("Primary", .primaryBlue)
                        colorSwatch("Background", .backgroundPrimary)
                        colorSwatch("Card", .cardBackground)
                        colorSwatch("Text", .textPrimary)
                    }
                }
                
                // Typography
                VStack(alignment: .leading, spacing: 8) {
                    Text("Typography").font(.title2).bold()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Navigation Title").font(.navigationTitle)
                        Text("Card Title").font(.cardTitle)
                        Text("Card Subtitle").font(.cardSubtitle)
                        Text("Body Text").font(.body)
                        Text("Caption").font(.caption1)
                    }
                }
                
                // Layout
                VStack(alignment: .leading, spacing: 8) {
                    Text("Layout").font(.title2).bold()
                    
                    VStack(spacing: 8) {
                        // Card example
                        LayoutComponents.userCardContainer {
                            HStack {
                                Circle()
                                    .fill(Color.primaryBlue)
                                    .avatarSize()
                                
                                VStack(alignment: .leading) {
                                    Text("User Name").cardTitleStyle()
                                    Text("user@email.com").cardSubtitleStyle()
                                }
                                
                                Spacer()
                            }
                        }
                        
                        // Buttons
                        HStack(spacing: 12) {
                            LayoutComponents.primaryButton {
                                Text("Primary")
                            }
                            
                            LayoutComponents.secondaryButton {
                                Text("Secondary")
                            }
                        }
                    }
                }
            }
            .screenPadding()
        }
        .background(Color.backgroundPrimary)
    }
    
    private func colorSwatch(_ name: String, _ color: Color) -> some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(width: 60, height: 40)
                .cornerRadius(8)
            
            Text(name)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
    }
}

struct ThemeDebugView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeDebugView()
            .applyTheme()
    }
}
#endif