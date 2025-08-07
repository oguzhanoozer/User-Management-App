//
//  UserListItemView.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct UserListItemView: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        LayoutComponents.userCardContainer {
            HStack(spacing: Spacing.md) {
                Circle()
                    .fill(Color.primaryBlue)
                    .avatarSize(Layout.avatarMedium)
                    .overlay(
                        Text(user.initials)
                            .font(.headline)
                            .foregroundColor(.textOnPrimary)
                            .fontWeight(.semibold)
                    )
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(user.name)
                        .cardTitleStyle()
                        .multilineTextAlignment(.leading)
                    
                    Text(user.email)
                        .cardSubtitleStyle()
                        .multilineTextAlignment(.leading)
                 
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
                    .iconSize()
            }
        }
        .onTapGesture {
            Logger.userAction("User item tapped", details: "User ID: \(user.id)")
            onTap()
        }
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        UserListItemView(user: User.mockUser) {
            // User tap handled in onTapGesture
        }
        
        UserListItemView(user: User.mockUsers[1]) {
            // User tap handled in onTapGesture
        }
    }
    .screenPadding()
    .background(Color.backgroundPrimary)
    .applyTheme()
}
