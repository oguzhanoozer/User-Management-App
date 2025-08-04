//
//  CreateEditUserViewModel.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation
import Combine

@MainActor
class CreateEditUserViewModel: ObservableObject {
    @Published var name = ""
    @Published var username = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var website = ""
    @Published var street = ""
    @Published var suite = ""
    @Published var city = ""
    @Published var zipcode = ""
    @Published var companyName = ""
    @Published var companyCatchPhrase = ""
    @Published var companyBS = ""
    
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var validationErrors: [String] = []
    
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    let mode: Mode
    let userId: Int?
    
    enum Mode {
        case create
        case edit(User)
        
        var title: String {
            switch self {
            case .create: return "Add User"
            case .edit: return "Edit User"
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .create: return "Create User"
            case .edit: return "Update User"
            }
        }
    }
    
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String {
        error?.errorDescription ?? "Unknown error"
    }
    
    var hasValidationErrors: Bool {
        !validationErrors.isEmpty
    }
    
    var isFormValid: Bool {
        validateForm().isEmpty
    }
    
    var canSubmit: Bool {
        !isLoading && isFormValid
    }
    
    init(
        mode: Mode,
        userService: UserServiceProtocol = ServiceLocator.shared.resolve(UserServiceProtocol.self)
    ) {
        self.mode = mode
        self.userService = userService
        
        switch mode {
        case .create:
            self.userId = nil
        case .edit(let user):
            self.userId = user.id
            populateFields(with: user)
        }
    }
    
    private func populateFields(with user: User) {
        name = user.name
        username = user.username
        email = user.email
        phone = user.phone
        website = user.website
        street = user.address.street
        suite = user.address.suite
        city = user.address.city
        zipcode = user.address.zipcode
        companyName = user.company.name
        companyCatchPhrase = user.company.catchPhrase
        companyBS = user.company.bs
    }
    
    func validateForm() -> [String] {
        var errors: [String] = []
        
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Name is required")
        }
        
        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Username is required")
        }
        
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Email is required")
        } else if !isValidEmail(email) {
            errors.append("Please enter a valid email address")
        }
        
        if phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Phone is required")
        }
        
        if street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Street address is required")
        }
        
        if city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("City is required")
        }
        
        if zipcode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Zipcode is required")
        }
        
        if companyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Company name is required")
        }
        
        return errors
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validateAndUpdateErrors() {
        validationErrors = validateForm()
    }
    
    func submitForm() {
        validateAndUpdateErrors()
        
        guard isFormValid else { return }
        
        isLoading = true
        error = nil
        
        switch mode {
        case .create:
            createUser()
        case .edit:
            updateUser()
        }
    }
    
    private func createUser() {
        let request = CreateUserRequest(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            address: CreateAddressRequest(
                street: street.trimmingCharacters(in: .whitespacesAndNewlines),
                suite: suite.trimmingCharacters(in: .whitespacesAndNewlines),
                city: city.trimmingCharacters(in: .whitespacesAndNewlines),
                zipcode: zipcode.trimmingCharacters(in: .whitespacesAndNewlines),
                geo: CreateGeoRequest(lat: "0.0", lng: "0.0")
            ),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            website: website.trimmingCharacters(in: .whitespacesAndNewlines),
            company: CreateCompanyRequest(
                name: companyName.trimmingCharacters(in: .whitespacesAndNewlines),
                catchPhrase: companyCatchPhrase.trimmingCharacters(in: .whitespacesAndNewlines),
                bs: companyBS.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        )
        
        Task {
            do {
                let newUser = try await userService.createUser(request)
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error as? APIError ?? .unknown(error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func updateUser() {
        guard let userId = userId else { return }
        
        let request = UpdateUserRequest(
            id: userId,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            address: CreateAddressRequest(
                street: street.trimmingCharacters(in: .whitespacesAndNewlines),
                suite: suite.trimmingCharacters(in: .whitespacesAndNewlines),
                city: city.trimmingCharacters(in: .whitespacesAndNewlines),
                zipcode: zipcode.trimmingCharacters(in: .whitespacesAndNewlines),
                geo: CreateGeoRequest(lat: "0.0", lng: "0.0")
            ),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            website: website.trimmingCharacters(in: .whitespacesAndNewlines),
            company: CreateCompanyRequest(
                name: companyName.trimmingCharacters(in: .whitespacesAndNewlines),
                catchPhrase: companyCatchPhrase.trimmingCharacters(in: .whitespacesAndNewlines),
                bs: companyBS.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        )
        
        Task {
            do {
                let updatedUser = try await userService.updateUser(id: userId, request)
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error as? APIError ?? .unknown(error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    func clearError() {
        error = nil
    }
    
    func clearValidationErrors() {
        validationErrors = []
    }
    
    func resetForm() {
        name = ""
        username = ""
        email = ""
        phone = ""
        website = ""
        street = ""
        suite = ""
        city = ""
        zipcode = ""
        companyName = ""
        companyCatchPhrase = ""
        companyBS = ""
        validationErrors = []
        error = nil
    }
}