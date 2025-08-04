//
//  ContentView.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Theme Preview Header
                    VStack(spacing: Spacing.sm) {
                        Text("User Management")
                            .primaryTitleStyle()
                        
                        Text("Theme System Installed ✅")
                            .captionStyle()
                    }
                    .sectionSpacing()
                    
                    // Sample User Card Preview
                    LayoutComponents.userCardContainer {
                        HStack(spacing: Spacing.md) {
                            // Avatar Placeholder
                            Circle()
                                .fill(Color.primaryBlue)
                                .avatarSize()
                                .overlay(
                                    Text("LG")
                                        .tagStyle()
                                        .font(.headline)
                                )
                            
                            VStack(alignment: .leading, spacing: Spacing.xs) {
                                Text("Leanne Graham")
                                    .cardTitleStyle()
                                
                                Text("Sincere@april.biz")
                                    .cardSubtitleStyle()
                                
                                HStack(spacing: Spacing.xs) {
                                    Text("Member")
                                        .tagStyle()
                                        .padding(.horizontal, Spacing.sm)
                                        .padding(.vertical, Spacing.xs)
                                        .background(Color.primaryBlue)
                                        .cornerRadius(Layout.cornerRadiusSmall)
                                    
                                    Spacer()
                                }
                            }
                            
                            Spacer()
                            
                            VStack(spacing: Spacing.xs) {
                                LayoutComponents.primaryButton {
                                    Text("View")
                                        .font(.buttonText)
                                }
                                .frame(width: 60, height: 32)
                            }
                        }
                    }
                    
                    // Theme Components Preview
                    VStack(spacing: Spacing.md) {
                        Text("Theme Components")
                            .sectionHeaderStyle()
                        
                        HStack(spacing: Spacing.md) {
                            LayoutComponents.primaryButton {
                                Text("Primary")
                            }
                            
                            LayoutComponents.secondaryButton {
                                Text("Secondary")
                            }
                        }
                    }
                    
                    Spacer()
                }
                .screenPadding()
            }
            .background(Color.backgroundPrimary)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
