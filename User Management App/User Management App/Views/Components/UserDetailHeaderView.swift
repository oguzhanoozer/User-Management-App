//
//  UserDetailHeaderView.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct UserDetailHeaderView: View {
    let user: User
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .iconSize()
                        .foregroundColor(.textPrimary)
                        .padding(Spacing.md)
                        .background(Color.backgroundSecondary.opacity(0.9))
                        .clipShape(Circle())
                }
                Spacer()
            }
            
            Circle()
                .fill(Color.white)
                .avatarSize(Layout.avatarXLarge)
                .overlay(
                    Text(user.initials)
                        .font(.largeTitle)
                        .foregroundColor(.primaryBlue)
                        .fontWeight(.bold)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: Spacing.sm) {
                Text(user.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.textOnPrimary)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.textOnPrimary.opacity(0.9))
                
                Text(user.displayRole)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryBlue)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.white)
                    .cornerRadius(Layout.cornerRadiusSmall)
            }
            
            Spacer(minLength: Spacing.lg)
        }
        .padding(.top, Spacing.xl)
        .padding(.horizontal, Spacing.screenHorizontal)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryBlue, Color.primaryBlueDark]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .frame(height: 320)
    }
} 