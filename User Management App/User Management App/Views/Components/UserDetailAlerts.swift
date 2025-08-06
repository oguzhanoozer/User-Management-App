//
//  UserDetailAlerts.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct UserDetailAlerts: ViewModifier {
    @Binding var showingEditAlert: Bool
    @Binding var showingDeleteAlert: Bool
    @Binding var showingSuccessAlert: Bool
    @Binding var editedName: String
    @Binding var editedEmail: String
    @Binding var alertMessage: String
    let onUpdate: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if showingEditAlert {
                        EditUserAlert(
                            editedName: $editedName,
                            editedEmail: $editedEmail,
                            onSave: {
                                onUpdate()
                                showingEditAlert = false
                            },
                            onCancel: {
                                showingEditAlert = false
                            }
                        )
                    }
                    
                    if showingDeleteAlert {
                        DeleteUserAlert(
                            onDelete: {
                                onDelete()
                                showingDeleteAlert = false
                            },
                            onCancel: {
                                showingDeleteAlert = false
                            }
                        )
                    }
                    
                    if showingSuccessAlert {
                        SuccessAlert(
                            message: alertMessage,
                            onDismiss: {
                                showingSuccessAlert = false
                                onDismiss()
                            }
                        )
                    }
                }
            )
    }
}

struct EditUserAlert: View {
    @Binding var editedName: String
    @Binding var editedEmail: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                Text(Strings.AlertTitles.editUser)
                    .cardTitleStyle()
                
                Text(Strings.FormSections.updateUserInfo)
                    .cardSubtitleStyle()
                    .multilineTextAlignment(.center)
                
                VStack(spacing: Spacing.md) {
                    TextField(Strings.Placeholders.name, text: $editedName)
                        .padding(Spacing.md)
                        .background(Color.backgroundSecondary)
                        .foregroundColor(.textPrimary)
                        .cornerRadius(Layout.cornerRadiusSmall)
                        .overlay(
                            RoundedRectangle(cornerRadius: Layout.cornerRadiusSmall)
                                .stroke(Color.borderColor, lineWidth: 1)
                        )
                    
                    TextField(Strings.Placeholders.emailField, text: $editedEmail)
                        .padding(Spacing.md)
                        .background(Color.backgroundSecondary)
                        .foregroundColor(.textPrimary)
                        .cornerRadius(Layout.cornerRadiusSmall)
                        .overlay(
                            RoundedRectangle(cornerRadius: Layout.cornerRadiusSmall)
                                .stroke(Color.borderColor, lineWidth: 1)
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                HStack(spacing: Spacing.md) {
                    Button(Strings.Actions.cancel) {
                        onCancel()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonHeight()
                    .background(Color.backgroundPrimary)
                    .foregroundColor(.textSecondary)
                    .buttonCornerRadius()
                    
                    Button(Strings.Actions.save) {
                        onSave()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonHeight()
                    .background(Color.primaryBlue)
                    .foregroundColor(.textOnPrimary)
                    .buttonCornerRadius()
                }
            }
            .padding(Spacing.xxl)
            .background(Color.backgroundSecondary)
            .cornerRadius(Layout.cornerRadiusLarge)
            .cardShadow()
            .padding(.horizontal, Spacing.screenHorizontal + Spacing.xxl)
        }
    }
}

struct DeleteUserAlert: View {
    let onDelete: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                Text(Strings.AlertTitles.deleteUser)
                    .cardTitleStyle()
                
                Text(Strings.AlertTitles.deleteConfirmation)
                    .cardSubtitleStyle()
                    .multilineTextAlignment(.center)
                
                HStack(spacing: Spacing.md) {
                    Button(Strings.Actions.cancel) {
                        onCancel()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonHeight()
                    .background(Color.backgroundPrimary)
                    .foregroundColor(.textSecondary)
                    .buttonCornerRadius()
                    
                    Button(Strings.Actions.delete) {
                        onDelete()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonHeight()
                    .background(Color.errorRed)
                    .foregroundColor(.textOnPrimary)
                    .buttonCornerRadius()
                }
            }
            .padding(Spacing.xxl)
            .background(Color.backgroundSecondary)
            .cornerRadius(Layout.cornerRadiusLarge)
            .cardShadow()
            .padding(.horizontal, Spacing.screenHorizontal + Spacing.xxl)
        }
    }
}

struct SuccessAlert: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                Text("Message:")
                    .cardTitleStyle()
                
                Text(message)
                    .cardSubtitleStyle()
                    .multilineTextAlignment(.center)
                
                Button(Strings.Actions.ok) {
                    onDismiss()
                }
                .frame(maxWidth: .infinity)
                .buttonHeight()
                .background(Color.primaryBlue)
                .foregroundColor(.textOnPrimary)
                .buttonCornerRadius()
            }
            .padding(Spacing.xxl)
            .background(Color.backgroundSecondary)
            .cornerRadius(Layout.cornerRadiusLarge)
            .cardShadow()
            .padding(.horizontal, Spacing.screenHorizontal + Spacing.xxl)
        }
    }
}
