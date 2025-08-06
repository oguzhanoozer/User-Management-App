//
//  AddUserViewModel.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation

@MainActor
class AddUserViewModel: ObservableObject {
    
    // MARK: - Published Properties - Form Fields
    @Published var name = "ozi"
    @Published var username = "ozi"
    @Published var email = "ozi@gmail.com"
    @Published var phone = "5382758345"
    
    // MARK: - Published Properties - Validation Errors
    @Published var nameError = ""
    @Published var usernameError = ""
    @Published var emailError = ""
    @Published var phoneError = ""
    
    // MARK: - Published Properties - UI State
    @Published var isCreating = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isSuccess = false
    
    // MARK: - Private Properties
    private let userService: UserServiceProtocol
    
    // MARK: - Computed Properties
    var isFormValid: Bool {
        return areFieldsFilled && areValidationsValid
    }
    
    private var areFieldsFilled: Bool {
        return !name.isEmpty && !username.isEmpty && !email.isEmpty && !phone.isEmpty
    }
    
    private var areValidationsValid: Bool {
        return nameError.isEmpty && usernameError.isEmpty &&
               emailError.isEmpty && phoneError.isEmpty
    }
    
    // MARK: - Initialization
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    // MARK: - Public Methods
    func createUser() async -> User? {
        logCreateUserStart()
        
        validateAllFields()
        
        guard isFormValid else {
            handleInvalidForm()
            return nil
        }
        
        return await performUserCreation()
    }
    
    func retryCreateUser() async -> User? {
        resetErrorState()
        return await createUser()
    }
    
    func resetForm() {
        resetFormFields()
        resetValidationErrors()
    }
    
    // MARK: - Validation Methods
    func validateName() {
        nameError = validateNameField(name)
    }
    
    func validateUsername() {
        usernameError = validateUsernameField(username)
    }
    
    func validateEmail() {
        emailError = validateEmailField(email)
    }
    
    func validatePhone() {
        phoneError = validatePhoneField(phone)
    }
    
    func validateAllFields() {
        validateName()
        validateUsername()
        validateEmail()
        validatePhone()
    }
}

// MARK: - Private Methods - User Creation
private extension AddUserViewModel {
    
    func logCreateUserStart() {
        print("=== CREATE USER WITH REAL BACKEND ===")
        print("API URL: https://jsonplaceholder.typicode.com/users")
    }
    
    func handleInvalidForm() {
        alertMessage = Strings.Validation.fillAllFields
        isSuccess = false
        showingAlert = true
    }
    
    func performUserCreation() async -> User? {
        setCreatingState(true)
        
        let createRequest = buildCreateRequest()
        
        do {
            let newUser = try await callBackendAPI(with: createRequest)
            handleCreationSuccess(newUser)
            return newUser
            
        } catch {
            handleCreationError(error)
            return nil
        }
    }
    
    func buildCreateRequest() -> CreateUserRequest {
        let cleanPhone = phone.filter { $0.isNumber }
        
        return CreateUserRequest(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
            phone: "+90\(cleanPhone)"
        )
    }
    
    func callBackendAPI(with request: CreateUserRequest) async throws -> User {
        print("🚀 CALLING REAL BACKEND API...")
        return try await userService.realCreateUser(request)
    }
    
    func handleCreationSuccess(_ user: User) {
        logCreationSuccess(user)
        
        alertMessage = Strings.Success.userCreated(
            name: user.name,
            email: user.email,
            phone: user.phone,
            id: user.id
        )
        isSuccess = true
        showingAlert = true
        setCreatingState(false)
    }
    
    func handleCreationError(_ error: Error) {
        logCreationError(error)
        
        let errorMessage = APIError.localizedMessage(from: error)
        alertMessage = "\(Strings.Errors.general): \(errorMessage)"
        isSuccess = false
        showingAlert = true
        setCreatingState(false)
    }
    
    func setCreatingState(_ isCreating: Bool) {
        self.isCreating = isCreating
    }
    
    func resetErrorState() {
        isCreating = false
        showingAlert = false
        alertMessage = ""
    }
}

// MARK: - Private Methods - Validation Logic
private extension AddUserViewModel {
    
    func validateNameField(_ name: String) -> String {
        if name.isEmpty {
            return Strings.Validation.Name.required
        } else if name.count < 2 {
            return Strings.Validation.Name.tooShort
        } else {
            return ""
        }
    }
    
    func validateUsernameField(_ username: String) -> String {
        if username.isEmpty {
            return Strings.Validation.Username.required
        } else if username.count < 3 {
            return Strings.Validation.Username.tooShort
        } else if !isValidUsernameFormat(username) {
            return Strings.Validation.Username.invalidCharacters
        } else {
            return ""
        }
    }
    
    func validateEmailField(_ email: String) -> String {
        if email.isEmpty {
            return Strings.Validation.Email.required
        } else if !isValidEmail(email) {
            return Strings.Validation.Email.invalid
        } else {
            return ""
        }
    }
    
    func validatePhoneField(_ phone: String) -> String {
        let cleanPhone = phone.filter { $0.isNumber }
        
        if phone.isEmpty {
            return Strings.Validation.Phone.required
        } else if cleanPhone.count != 10 {
            return Strings.Validation.Phone.invalidLength
        } else {
            return ""
        }
    }
    
    func isValidUsernameFormat(_ username: String) -> Bool {
        return username.allSatisfy { $0.isLetter || $0.isNumber || $0 == "_" }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Private Methods - Form Management
private extension AddUserViewModel {
    
    func resetFormFields() {
        name = ""
        username = ""
        email = ""
        phone = ""
    }
    
    func resetValidationErrors() {
        nameError = ""
        usernameError = ""
        emailError = ""
        phoneError = ""
    }
}

// MARK: - Private Methods - Logging
private extension AddUserViewModel {
    
    func logCreationSuccess(_ user: User) {
        print("✅ USER CREATED SUCCESSFULLY:")
        print("- ID: \(user.id)")
        print("- Name: \(user.name)")
        print("- Username: \(user.username)")
        print("- Email: \(user.email)")
        print("- Phone: \(user.phone)")
    }
    
    func logCreationError(_ error: Error) {
        print("❌ USER CREATION FAILED: \(error)")
    }
}
