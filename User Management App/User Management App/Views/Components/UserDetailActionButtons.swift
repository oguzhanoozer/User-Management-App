//
//  UserDetailActionButtons.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct UserDetailActionButtons: View {
    let user: User
    let isUpdating: Bool
    let isDeleting: Bool
    let onCall: () -> Void
    let onMessage: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onSendEmail: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                Button(action: onCall) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .iconSize()
                        Text(Strings.DetailRows.call)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.successGreen)
                    .foregroundColor(.white)
                    .cornerRadius(Layout.buttonCornerRadius)
                }
                
                Button(action: onMessage) {
                    HStack {
                        Image(systemName: "message.fill")
                            .iconSize()
                        Text(Strings.DetailRows.message)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.infoBlue)
                    .foregroundColor(.white)
                    .cornerRadius(Layout.buttonCornerRadius)
                }
            }
            
            HStack(spacing: Spacing.md) {
                Button(action: onEdit) {
                    HStack {
                        if isUpdating {
                            AppProgressView.button
                        } else {
                            Image(systemName: "pencil")
                                .iconSize()
                        }
                        Text(Strings.Actions.edit)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.warningOrange)
                    .foregroundColor(.white)
                    .cornerRadius(Layout.buttonCornerRadius)
                }
                .disabled(isUpdating)
                
                Button(action: onDelete) {
                    HStack {
                        if isDeleting {
                            AppProgressView.button
                        } else {
                            Image(systemName: "trash")
                                .iconSize()
                        }
                        Text(Strings.Actions.delete)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.errorRed)
                    .foregroundColor(.white)
                    .cornerRadius(Layout.buttonCornerRadius)
                }
                .disabled(isDeleting || isUpdating)
            }
            
            Button(action: onSendEmail) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .iconSize()
                    Text(Strings.DetailRows.sendEmail)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primaryBlue)
                .foregroundColor(.white)
                .cornerRadius(Layout.buttonCornerRadius)
            }
        }
    }
} 
