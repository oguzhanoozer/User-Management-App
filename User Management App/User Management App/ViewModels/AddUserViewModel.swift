//
//  AddUserViewModel.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation

@MainActor
class AddUserViewModel: ObservableObject {
    
    @Published var name = ""
    @Published var username = ""
    @Published var email = ""
    @Published var phone = ""
    
    @Published var nameError = ""
    @Published var usernameError = ""
    @Published var emailError = ""
    @Published var phoneError = ""
    
    @Published var isCreating = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isSuccess = false
    
    private let userService: UserServiceProtocol
    
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
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    func createUser() async -> User? {
        
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

private extension AddUserViewModel {
    
   
    
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

private extension AddUserViewModel {
    
    func logCreationSuccess(_ user: User) {
        Logger.apiSuccess("User created successfully")
        Logger.debug("Created user - ID: \(user.id), Name: \(user.name), Username: \(user.username), Email: \(user.email), Phone: \(user.phone)", category: .api)
    }
    
    func logCreationError(_ error: Error) {
        Logger.apiError(error, endpoint: "createUser")
    }
}
