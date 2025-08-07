//
//  UserDetailView.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct UserDetailView: View {
    let userId: Int
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: UserDetailViewModel
    @State private var showingEditAlert = false
    @State private var showingDeleteAlert = false
    @State private var editedName = ""
    @State private var editedEmail = ""
    @State private var showingSuccessAlert = false
    @State private var alertMessage = ""
    @State private var isLoadingDetail = true
    
    init(userId: Int) {
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: UserDetailViewModel(userId: userId))
    }
    
    var body: some View {
        ZStack {
            Color.backgroundSecondary
                .ignoresSafeArea()
            
            if let user = viewModel.user {
                ScrollView {
                    VStack(spacing: 0) {
                        UserDetailHeaderView(user: user, onDismiss: { dismiss() })
                        
                        UserDetailContent(
                            user: user,
                            isUpdating: viewModel.isUpdating,
                            isDeleting: viewModel.isDeleting,
                            onCall: {},
                            onMessage: {},
                            onEdit: {
                                editedName = user.name
                                editedEmail = user.email
                                showingEditAlert = true
                            },
                            onDelete: {
                                showingDeleteAlert = true
                            },
                            onSendEmail: {}
                        )
                    }
                }
            } else if viewModel.hasError {
                VStack {
                    Spacer()
                    
                    Text(viewModel.errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button("Try Again") {
                        viewModel.retryLoadUser()
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
            
            UserDetailLoadingOverlay(
                isUpdating: viewModel.isUpdating,
                isDeleting: viewModel.isDeleting,
                isLoadingDetail: isLoadingDetail
            )
        }
        .onAppear {
            viewModel.loadUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoadingDetail = false
            }
        }
        .modifier(UserDetailAlerts(
            showingEditAlert: $showingEditAlert,
            showingDeleteAlert: $showingDeleteAlert,
            showingSuccessAlert: $showingSuccessAlert,
            editedName: $editedName,
            editedEmail: $editedEmail,
            alertMessage: $alertMessage,
            onUpdate: updateUser,
            onDelete: deleteUser,
            onDismiss: { dismiss() }
        ))
    }
}


extension UserDetailView {
    private func updateUser() {
        Task {
            let success = await viewModel.updateUser(name: editedName, email: editedEmail)
            
            if success {
                alertMessage = Strings.Success.userUpdated(name: editedName, email: editedEmail)
            } else {
                alertMessage = Strings.Errors.updateFailed(viewModel.errorMessage)
            }
            showingSuccessAlert = true
        }
    }
    
    private func deleteUser() {
        Task {
            let success = await viewModel.deleteUser()
            
            if success {
                alertMessage = Strings.Success.userDeleted(name: viewModel.user?.name ?? "User")
                showingSuccessAlert = true
            } else {
                alertMessage = Strings.Errors.deleteFailed(viewModel.errorMessage)
                showingSuccessAlert = true
            }
        }
    }
}


struct DetailSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .sectionHeaderStyle()
            
            LayoutComponents.cardContainer {
                content
            }
        }
    }
}

struct DetailRowView: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    init(icon: String, title: String, value: String, iconColor: Color = .primaryBlue) {
        self.icon = icon
        self.title = title
        self.value = value
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .iconSize()
                .frame(width: Layout.iconLarge)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}

#Preview {
    UserDetailView(userId: 1)
        .applyTheme()
}
