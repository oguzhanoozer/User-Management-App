//
//  AddUserView.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import SwiftUI

struct AddUserView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    
    @State private var isCreating = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    // Validation states
    @State private var nameError = ""
    @State private var usernameError = ""
    @State private var emailError = ""
    @State private var phoneError = ""
    
    let onUserAdded: (User) -> Void
    
    var isFormValid: Bool {
        return !name.isEmpty && !username.isEmpty && !email.isEmpty && !phone.isEmpty &&
               nameError.isEmpty && usernameError.isEmpty && emailError.isEmpty && phoneError.isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Header
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
                        
                        // User Information Section
                        FormSectionView(title: Strings.FormSections.userInfo) {
                            VStack(spacing: Spacing.md) {
                                FormFieldView(
                                    title: Strings.FormFields.fullName,
                                    text: $name,
                                    placeholder: Strings.Placeholders.fullName,
                                    errorMessage: nameError
                                )
                                .onChange(of: name) { _ in
                                    validateName()
                                }
                                
                                FormFieldView(
                                    title: Strings.FormFields.username,
                                    text: $username,
                                    placeholder: Strings.Placeholders.username,
                                    errorMessage: usernameError
                                )
                                .onChange(of: username) { _ in
                                    validateUsername()
                                }
                                
                                FormFieldView(
                                    title: Strings.FormFields.email,
                                    text: $email,
                                    placeholder: Strings.Placeholders.email,
                                    errorMessage: emailError,
                                    keyboardType: .emailAddress
                                )
                                .onChange(of: email) { _ in
                                    validateEmail()
                                }
                                
                                FormFieldView(
                                    title: Strings.FormFields.phone,
                                    text: $phone,
                                    placeholder: Strings.Placeholders.phone,
                                    errorMessage: phoneError,
                                    keyboardType: .phonePad
                                )
                                .onChange(of: phone) { _ in
                                    validatePhone()
                                }
                            }
                        }
                        
                        // Action Buttons
                        VStack(spacing: Spacing.md) {
                            Button(action: {
                                createUser()
                            }) {
                                HStack {
                                    if isCreating {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "person.badge.plus")
                                            .iconSize()
                                    }
                                    Text(isCreating ? "Kullanıcı Ekleniyor..." : "Kullanıcı Ekle")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid && !isCreating ? Color.primaryBlue : Color.textTertiary)
                                .foregroundColor(.white)
                                .cornerRadius(Layout.buttonCornerRadius)
                            }
                            .disabled(!isFormValid || isCreating)
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("İptal")
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
                            .disabled(isCreating)
                        }
                        
                        Spacer(minLength: Spacing.xxxl)
                    }
                    .screenPadding()
                }
                
                // Creating User Loading Overlay
                if isCreating {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: Spacing.lg) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            
                            Text(Strings.Loading.creating)
                                .font(.headline)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                            
                            Text(Strings.Loading.backendSync)
                                .captionStyle()
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(Spacing.xxl)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(Layout.cornerRadiusLarge)
                    }
                }
            }
        }
        .navigationTitle(Strings.Navigation.newUser)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(Strings.Actions.cancel) {
                    dismiss()
                }
                .disabled(isCreating)
            }
        }
        .alert(Strings.AlertTitles.result, isPresented: $showingAlert) {
            Button(Strings.Actions.ok) {
                if isSuccess {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
}

// MARK: - AddUserView Methods
extension AddUserView {
    // MARK: - Validation Functions
    private func validateName() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            nameError = Strings.Validation.Name.required
        } else if trimmedName.count < 2 {
            nameError = Strings.Validation.Name.tooShort
        } else if trimmedName.count > 50 {
            nameError = Strings.Validation.Name.tooLong
        } else {
            nameError = ""
        }
    }
    
    private func validateUsername() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedUsername.isEmpty {
            usernameError = Strings.Validation.Username.required
        } else if trimmedUsername.count < 3 {
            usernameError = Strings.Validation.Username.tooShort
        } else if trimmedUsername.count > 20 {
            usernameError = Strings.Validation.Username.tooLong
        } else if !trimmedUsername.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" || $0 == "." }) {
            usernameError = Strings.Validation.Username.invalidCharacters
        } else {
            usernameError = ""
        }
    }
    
    private func validateEmail() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty {
            emailError = Strings.Validation.Email.required
        } else if !isValidEmail(trimmedEmail) {
            emailError = Strings.Validation.Email.invalid
        } else {
            emailError = ""
        }
    }
    
    private func validatePhone() {
        let cleanPhone = phone.filter { $0.isNumber }
        if cleanPhone.isEmpty {
            phoneError = Strings.Validation.Phone.required
        } else if cleanPhone.count != 10 {
            phoneError = Strings.Validation.Phone.invalidLength
        } else {
            phoneError = ""
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - User Creation
    private func createUser() {
        print("=== CREATE USER WITH REAL BACKEND ===")
        print("API URL: https://jsonplaceholder.typicode.com/users")
        
        // Validate all fields
        validateName()
        validateUsername()
        validateEmail()
        validatePhone()
        
        guard isFormValid else {
            alertMessage = Strings.Validation.fillAllFields
            isSuccess = false
            showingAlert = true
            return
        }
        
        isCreating = true
        let cleanPhone = phone.filter { $0.isNumber }
        
        let createRequest = CreateUserRequest(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
            address: CreateAddressRequest(
                street: "Kulas Light",
                suite: "Apt. 556",
                city: "Gwenborough",
                zipcode: "92998-3874",
                geo: CreateGeoRequest(lat: "-37.3159", lng: "81.1496")
            ),
            phone: "+90\(cleanPhone)",
            website: "\(username.lowercased()).org",
            company: CreateCompanyRequest(
                name: "Technology Solutions",
                catchPhrase: "Multi-layered client-server neural-net",
                bs: "harness real-time e-markets"
            )
        )
        
        Task {
            do {
                print("🚀 CALLING REAL BACKEND API...")
                let userService = ServiceLocator.shared.resolve(UserServiceProtocol.self)
                let newUser = try await userService.createUser(createRequest)
                
                await MainActor.run {
                    print("✅ BACKEND API SUCCESS: User created with ID \(newUser.id)")
                    onUserAdded(newUser)
                    alertMessage = Strings.Success.userCreated(name: newUser.name, email: newUser.email, phone: newUser.phone, id: newUser.id)
                    isSuccess = true
                    showingAlert = true
                    isCreating = false
                }
            } catch {
                await MainActor.run {
                    print("❌ BACKEND API ERROR: \(error)")
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .networkError(let message):
                            alertMessage = Strings.Errors.network(message)
                        case .noData:
                            alertMessage = Strings.Errors.serverResponse
                        case .decodingError(let message):
                            alertMessage = Strings.Errors.dataDecoding(message)
                        case .invalidURL:
                            alertMessage = Strings.Errors.invalidURL
                        case .serverError(let code, let message):
                            alertMessage = Strings.Errors.serverError(code, message)
                        case .timeoutError:
                            alertMessage = Strings.Errors.timeout
                        case .noInternetConnection:
                            alertMessage = Strings.Errors.noInternet
                        case .unknown(let message):
                            alertMessage = Strings.Errors.unknown(message)
                        }
                    } else {
                        alertMessage = Strings.Errors.apiGeneral(error.localizedDescription)
                    }
                    isSuccess = false
                    showingAlert = true
                    isCreating = false
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct FormSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text(title)
                    .sectionHeaderStyle()
                Spacer()
            }
            
            VStack(spacing: Spacing.md) {
                content
            }
            .padding(Spacing.lg)
            .background(Color.backgroundSecondary)
            .cornerRadius(Layout.cornerRadiusMedium)
        }
    }
}

struct FormFieldView: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let errorMessage: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.errorRed)
            }
        }
    }
}

#Preview {
    AddUserView { user in
        print("User added: \(user.name)")
    }
    .applyTheme()
}