//
//  UserDetailLoadingOverlay.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct UserDetailLoadingOverlay: View {
    let isUpdating: Bool
    let isDeleting: Bool
    let isLoadingDetail: Bool
    
    var body: some View {
        ZStack {
            if isUpdating || isDeleting {
                Color.backgroundPrimary.opacity(0.8)
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.md) {
                    AppProgressView.primary

                    
                    Text(isUpdating ? Strings.Loading.updating : Strings.Loading.deleting)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                        .fontWeight(.semibold)
                }
                .padding(Spacing.xxl)
                .background(Color.backgroundSecondary)
                .border(Color.borderColor, width: 1)
                .cornerRadius(Layout.cornerRadiusLarge)
            }
            
            if isLoadingDetail {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: Spacing.lg) {
                    AppProgressView.primary

                    Text(Strings.Loading.userDetail)
                        .font(.headline)
                        .foregroundColor(.primaryBlue)
                        .fontWeight(.semibold)
                }
            }
        }
    }
} 
