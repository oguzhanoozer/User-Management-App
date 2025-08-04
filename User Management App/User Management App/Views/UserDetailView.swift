//
//  UserDetailView.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct UserDetailView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: UserDetailViewModel
    @State private var showingEditAlert = false
    @State private var showingDeleteAlert = false
    @State private var editedName = ""
    @State private var editedEmail = ""
    @State private var showingSuccessAlert = false
    @State private var alertMessage = ""
    @State private var isLoadingDetail = true
    
    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: UserDetailViewModel(userId: user.id))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section with gradient background
                    VStack(spacing: Spacing.lg) {
                        // Close button
                        HStack {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .iconSize()
                                    .foregroundColor(.textOnPrimary)
                                    .padding(Spacing.md)
                                    .background(Color.black.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        
                        // Large Avatar
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
                            
                            // Role Tag
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
                    
                    // Content Section
                    VStack(spacing: Spacing.lg) {
                        // Contact Information
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
                        
                        // Address Information
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
                                        title: "Posta Kodu",
                                        value: user.address.zipcode,
                                        iconColor: .textTertiary
                                    )
                                }
                            }
                        }
                        
                        // Company Information
                        DetailSectionView(title: "Şirket Bilgileri") {
                            VStack(spacing: Spacing.md) {
                                DetailRowView(
                                    icon: "building.fill",
                                    title: "Şirket Adı",
                                    value: user.company.name,
                                    iconColor: .primaryBlue
                                )
                                
                                Divider()
                                
                                DetailRowView(
                                    icon: "quote.bubble.fill",
                                    title: "Slogan",
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
                        
                        // Action Buttons
                        VStack(spacing: Spacing.md) {
                            // First row: Call and Message
                            HStack(spacing: Spacing.md) {
                                Button(action: {
                                    // Call action implementation
                                }) {
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
                                
                                Button(action: {
                                    // Message action implementation
                                }) {
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
                            
                            // Second row: Edit and Delete
                            HStack(spacing: Spacing.md) {
                                Button(action: {
                                    editedName = user.name
                                    editedEmail = user.email
                                    showingEditAlert = true
                                }) {
                                    HStack {
                                        if viewModel.isUpdating {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
                                .disabled(viewModel.isUpdating)
                                
                                Button(action: {
                                    showingDeleteAlert = true
                                }) {
                                    HStack {
                                        if viewModel.isDeleting {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
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
                                .disabled(viewModel.isDeleting || viewModel.isUpdating)
                            }
                            
                            // Third row: Email
                            Button(action: {
                                // Email action implementation
                            }) {
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
                        
                        Spacer(minLength: Spacing.xxxl)
                    }
                    .padding(.top, Spacing.lg)
                    .screenPadding()
                }
            }
            
            // Update/Delete Loading Overlay
            if viewModel.isUpdating || viewModel.isDeleting {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: Spacing.md) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        
                        Text(viewModel.isUpdating ? "Güncelleniyor..." : "Siliniyor...")
                            .font(.headline)
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .padding(Spacing.xxl)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(Layout.cornerRadiusLarge)
                }
            }
            
            // Initial Detail Loading
            if isLoadingDetail {
                ZStack {
                    Color.backgroundPrimary
                        .ignoresSafeArea()
                    
                    VStack(spacing: Spacing.lg) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryBlue))
                        
                        Text("Kullanıcı detayı yükleniyor...")
                            .font(.headline)
                            .foregroundColor(.primaryBlue)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .background(Color.backgroundPrimary)
        .onAppear {
            // Simulate detail loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoadingDetail = false
            }
            viewModel.user = user
        }
        .alert("Kullanıcı Düzenle", isPresented: $showingEditAlert) {
            TextField(Strings.Placeholders.name, text: $editedName)
            TextField(Strings.Placeholders.emailField, text: $editedEmail)
            Button(Strings.Actions.save) {
                updateUser()
            }
            Button("İptal", role: .cancel) { }
        } message: {
            Text(Strings.FormSections.updateUserInfo)
        }
        .alert("Kullanıcı Sil", isPresented: $showingDeleteAlert) {
            Button("Sil", role: .destructive) {
                deleteUser()
            }
            Button("İptal", role: .cancel) { }
        } message: {
            Text(Strings.AlertTitles.deleteConfirmation)
        }
        .alert("İşlem Sonucu", isPresented: $showingSuccessAlert) {
            Button(Strings.Actions.ok) {
                if alertMessage.contains("silindi") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
}

// MARK: - UserDetailView Methods
extension UserDetailView {
    private func updateUser() {
        print("=== UPDATE USER WITH REAL BACKEND ===")
        print("PUT https://jsonplaceholder.typicode.com/users/\(user.id)")
        print("Original User: \(user.name) - \(user.email)")
        print("Updated Name: \(editedName)")
        print("Updated Email: \(editedEmail)")
        
        let currentUser = viewModel.user ?? user
        let updatedUser = User(
            id: currentUser.id,
            name: editedName,
            username: currentUser.username,
            email: editedEmail,
            address: currentUser.address,
            phone: currentUser.phone,
            website: currentUser.website,
            company: currentUser.company
        )
        
        Task {
            print("🚀 CALLING REAL BACKEND API FOR UPDATE...")
            viewModel.updateUser(updatedUser)
            
            // Wait for the operation to complete
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            
            await MainActor.run {
                print("Backend API update operation completed")
                print("Error: \(String(describing: viewModel.error))")
                
                if viewModel.error != nil {
                    alertMessage = Strings.Errors.updateFailed(viewModel.errorMessage)
                    print("Backend update failed: \(viewModel.errorMessage)")
                } else {
                    alertMessage = Strings.Success.userUpdated(name: editedName, email: editedEmail)
                    print("Backend update successful!")
                }
                showingSuccessAlert = true
            }
        }
    }
    
    private func deleteUser() {
        print("=== DELETE USER WITH REAL BACKEND ===")
        print("DELETE https://jsonplaceholder.typicode.com/users/\(user.id)")
        print("Deleting User: \(user.name) (ID: \(user.id))")
        
        Task {
            print("🚀 CALLING REAL BACKEND API FOR DELETE...")
            let success = viewModel.deleteUser()
            print("Backend delete operation returned: \(success)")
            
            if success {
                // Wait a bit for the operation to complete
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                
                await MainActor.run {
                    print("Backend API delete operation completed")
                    print("Error: \(String(describing: viewModel.error))")
                    
                    if viewModel.error != nil {
                        alertMessage = Strings.Errors.deleteFailed(viewModel.errorMessage)
                        print("Backend delete failed: \(viewModel.errorMessage)")
                    } else {
                        alertMessage = Strings.Success.userDeleted(name: user.name)
                        print("Backend delete successful!")
                    }
                    showingSuccessAlert = true
                }
            } else {
                print("Backend delete operation failed immediately")
                alertMessage = Strings.Errors.deleteNotStarted
                showingSuccessAlert = true
            }
        }
    }
}

// MARK: - Supporting Views
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
    UserDetailView(user: User.mockUser)
        .applyTheme()
}