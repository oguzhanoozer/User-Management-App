//
//  UserDetailContent.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct UserDetailContent: View {
    let user: User
    let isUpdating: Bool
    let isDeleting: Bool
    let onCall: () -> Void
    let onMessage: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSendEmail: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            DetailSectionView(title: Strings.DetailSections.contactInfo) {
                VStack(spacing: Spacing.md) {
                    DetailRowView(
                        icon: "envelope.fill",
                        title: Strings.DetailRows.email,
                        value: user.email,
                        iconColor: .primaryBlue
                    )
                    
                    Divider()
                    
                    DetailRowView(
                        icon: "phone.fill",
                        title: Strings.DetailRows.phone,
                        value: user.phone,
                        iconColor: .successGreen
                    )
                    
                    Divider()
                    
                    DetailRowView(
                        icon: "globe",
                        title: Strings.DetailRows.website,
                        value: user.website,
                        iconColor: .infoBlue
                    )
                }
            }
            
            DetailSectionView(title: Strings.DetailSections.addressInfo) {
                VStack(spacing: Spacing.md) {
                    DetailRowView(
                        icon: "location.fill",
                        title: Strings.DetailRows.fullAddress,
                        value: user.fullAddress,
                        iconColor: .errorRed
                    )
                    
                    Divider()
                    
                    HStack(spacing: Spacing.md) {
                        DetailRowView(
                            icon: "building.2.fill",
                            title: Strings.DetailRows.city,
                            value: user.address.city,
                            iconColor: .warningOrange
                        )
                        
                        Spacer()
                        
                        DetailRowView(
                            icon: "number",
                            title: Strings.Detail.zipCode,
                            value: user.address.zipcode,
                            iconColor: .textTertiary
                        )
                    }
                }
            }
            
            DetailSectionView(title: "Company Information") {
                VStack(spacing: Spacing.md) {
                    DetailRowView(
                        icon: "building.fill",
                        title: "Company Name",
                        value: user.company.name,
                        iconColor: .primaryBlue
                    )
                    
                    Divider()
                    
                    DetailRowView(
                        icon: "quote.bubble.fill",
                        title: Strings.Detail.slogan,
                        value: user.company.catchPhrase,
                        iconColor: .infoBlue
                    )
                    
                    Divider()
                    
                    DetailRowView(
                        icon: "briefcase.fill",
                        title: "İş Alanı",
                        value: user.company.businessType,
                        iconColor: .successGreen
                    )
                }
            }
            
            UserDetailActionButtons(
                user: user,
                isUpdating: isUpdating,
                isDeleting: isDeleting,
                onCall: onCall,
                onMessage: onMessage,
                onEdit: onEdit,
                onDelete: onDelete,
                onSendEmail: onSendEmail
            )
            
            Spacer(minLength: Spacing.xxxl)
        }
        .padding(.top, Spacing.lg)
        .screenPadding()
    }
} 
