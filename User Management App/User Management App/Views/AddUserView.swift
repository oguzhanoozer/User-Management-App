//
//  AddUserView.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct AddUserView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddUserViewModel()
    
    let onUserAdded: (User) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundSecondary
                    .ignoresSafeArea()
                
                MainFormView(viewModel: viewModel, onUserAdded: onUserAdded)
                
                if viewModel.isCreating {
                    LoadingOverlay()
                }
            }
        }
        .navigationTitle(Strings.Navigation.newUser)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                CancelButton(
                    isDisabled: viewModel.isCreating,
                    onCancel: { dismiss() }
                )
            }
        }
        .alert(Strings.AlertTitles.result, isPresented: $viewModel.showingAlert) {
            AlertButtons(viewModel: viewModel, onUserAdded: onUserAdded, onDismiss: { dismiss() })
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

// MARK: - Main Form View
struct MainFormView: View {
    @ObservedObject var viewModel: AddUserViewModel
    let onUserAdded: (User) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                HeaderSection()
                
                UserInfoFormSection(viewModel: viewModel)
                
                ActionButtonsSection(
                    viewModel: viewModel,
                    onCreateUser: {
                        Task {
                            if let newUser = await viewModel.createUser() {
                                onUserAdded(newUser)
                            }
                        }
                    }
                )
                
                Spacer(minLength: Spacing.xxxl)
            }
            .screenPadding()
        }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "person.badge.plus")
                .iconSize(Layout.iconXLarge)
                .foregroundColor(.primaryBlue)
            
            Text(Strings.FormSections.newUser)
                .primaryTitleStyle()
            
            Text(Strings.FormSections.fillAllFields)
                .captionStyle()
        }
        .sectionSpacing()
    }
}

// MARK: - User Info Form Section
struct UserInfoFormSection: View {
    @ObservedObject var viewModel: AddUserViewModel
    
    var body: some View {
        FormSectionView(title: Strings.FormSections.userInfo) {
            VStack(spacing: Spacing.md) {
                NameField(viewModel: viewModel)
                UsernameField(viewModel: viewModel)
                EmailField(viewModel: viewModel)
                PhoneField(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Form Fields
struct NameField: View {
    @ObservedObject var viewModel: AddUserViewModel
    
    var body: some View {
        FormFieldView(
            title: Strings.FormFields.fullName,
            text: $viewModel.name,
            placeholder: Strings.Placeholders.fullName,
            errorMessage: viewModel.nameError
        )
        .onChange(of: viewModel.name) { _ in
            viewModel.validateName()
        }
    }
}

struct UsernameField: View {
    @ObservedObject var viewModel: AddUserViewModel
    
    var body: some View {
        FormFieldView(
            title: Strings.FormFields.username,
            text: $viewModel.username,
            placeholder: Strings.Placeholders.username,
            errorMessage: viewModel.usernameError
        )
        .onChange(of: viewModel.username) { _ in
            viewModel.validateUsername()
        }
    }
}

struct EmailField: View {
    @ObservedObject var viewModel: AddUserViewModel
    
    var body: some View {
        FormFieldView(
            title: Strings.FormFields.email,
            text: $viewModel.email,
            placeholder: Strings.Placeholders.email,
            errorMessage: viewModel.emailError,
            keyboardType: .emailAddress
        )
        .onChange(of: viewModel.email) { _ in
            viewModel.validateEmail()
        }
    }
}

struct PhoneField: View {
    @ObservedObject var viewModel: AddUserViewModel
    
    var body: some View {
        FormFieldView(
            title: Strings.FormFields.phone,
            text: $viewModel.phone,
            placeholder: Strings.Placeholders.phone,
            errorMessage: viewModel.phoneError,
            keyboardType: .phonePad,
            maxLength: 10
        )
        .onChange(of: viewModel.phone) { _ in
            viewModel.validatePhone()
        }
    }
}

// MARK: - Action Buttons Section
struct ActionButtonsSection: View {
    @ObservedObject var viewModel: AddUserViewModel
    let onCreateUser: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            CreateUserButton(
                viewModel: viewModel,
                onCreateUser: onCreateUser
            )
            
            CancelFormButton(
                isDisabled: viewModel.isCreating,
                onCancel: {
                    // Handle cancel from form body
                }
            )
        }
    }
}

// MARK: - Create User Button
struct CreateUserButton: View {
    @ObservedObject var viewModel: AddUserViewModel
    let onCreateUser: () -> Void
    
    var body: some View {
        Button(action: onCreateUser) {
            HStack {
                if viewModel.isCreating {
                    AppProgressView.button

                } else {
                    Image(systemName: "person.badge.plus")
                        .iconSize()
                }
                Text(viewModel.isCreating ? Strings.Buttons.addingUser : Strings.Buttons.addUser)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(buttonBackgroundColor)
            .foregroundColor(.white)
            .cornerRadius(Layout.buttonCornerRadius)
        }
        .disabled(!viewModel.isFormValid || viewModel.isCreating)
    }
    
    private var buttonBackgroundColor: Color {
        viewModel.isFormValid && !viewModel.isCreating ? Color.primaryBlue : Color.textTertiary
    }
}

// MARK: - Cancel Buttons
struct CancelButton: View {
    let isDisabled: Bool
    let onCancel: () -> Void
    
    var body: some View {
        Button(Strings.Actions.cancel) {
            onCancel()
        }
        .disabled(isDisabled)
    }
}

struct CancelFormButton: View {
    let isDisabled: Bool
    let onCancel: () -> Void
    
    var body: some View {
        Button(action: onCancel) {
            Text(Strings.Actions.cancel)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.backgroundSecondary)
                .foregroundColor(.textPrimary)
                .cornerRadius(Layout.buttonCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.buttonCornerRadius)
                        .stroke(Color.borderColor, lineWidth: 1)
                )
        }
        .disabled(isDisabled)
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.backgroundPrimary.opacity(0.8)
                .ignoresSafeArea()
            
            LoadingContent()
        }
    }
}

struct LoadingContent: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            AppProgressView.primary

            Text(Strings.Loading.creating)
                .font(.headline)
                .foregroundColor(.textPrimary)
                .fontWeight(.semibold)
            
            Text(Strings.Loading.backendSync)
                .captionStyle()
                .foregroundColor(.textSecondary)
        }
        .padding(Spacing.xxl)
        .background(Color.backgroundSecondary)
        .border(Color.borderColor, width: 1)
        .cornerRadius(Layout.cornerRadiusLarge)
    }
}

// MARK: - Alert Buttons
struct AlertButtons: View {
    @ObservedObject var viewModel: AddUserViewModel
    let onUserAdded: (User) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        Group {
            if viewModel.isSuccess {
                Button(Strings.Actions.ok) {
                    onDismiss()
                }
            } else {
                Button("Retry") {
                    Task {
                        if let newUser = await viewModel.retryCreateUser() {
                            onUserAdded(newUser)
                        }
                    }
                }
                Button(Strings.Actions.cancel, role: .cancel) { }
            }
        }
    }
}

// MARK: - Form Section View
struct FormSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: title)
            SectionContent(content: content)
        }
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .sectionHeaderStyle()
            Spacer()
        }
    }
}

struct SectionContent<Content: View>: View {
    let content: Content
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            content
        }
        .padding(Spacing.lg)
        .background(Color.backgroundSecondary)
        .cornerRadius(Layout.cornerRadiusMedium)
    }
}

// MARK: - Form Field View
struct FormFieldView: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let errorMessage: String
    var keyboardType: UIKeyboardType = .default
    var maxLength: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            FieldTitle(title: title)
            FieldInput(
                text: $text,
                placeholder: placeholder,
                keyboardType: keyboardType,
                maxLength: maxLength
            )
            FieldError(errorMessage: errorMessage)
        }
    }
}

struct FieldTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.textPrimary)
    }
}

struct FieldInput: View {
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let maxLength: Int?
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.backgroundSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusSmall)
                    .stroke(Color.borderColor, lineWidth: 1)
            )
            .cornerRadius(Layout.cornerRadiusSmall)
            .keyboardType(keyboardType)
            .foregroundStyle(Color.textPrimary)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.none)
            .onChange(of: text) { newValue in
                if let maxLength = maxLength, newValue.count > maxLength {
                    text = String(newValue.prefix(maxLength))
                }
            }
    }
}

struct FieldError: View {
    let errorMessage: String
    
    var body: some View {
        if !errorMessage.isEmpty {
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(.errorRed)
        }
    }
}

#Preview {
    AddUserView { user in
        print("User added: \(user.name)")
    }
    .applyTheme()
}
