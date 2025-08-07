//
//  UserDetailViewModel.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation

@MainActor
class UserDetailViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var isDeleting = false
    @Published var isUpdating = false
    @Published var showDeleteConfirmation = false
    
    private let userService: UserServiceProtocol
    private let userId: Int
    
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String {
        if let error = error {
            return APIError.localizedMessage(from: error)
        }
        return Strings.CommonErrors.unknown
    }
    
    var canPerformActions: Bool {
        !isLoading && !isDeleting && !isUpdating
    }
    
    init(userId: Int) {
        self.userId = userId
        self.userService = UserService()
    }
    
    func loadUser() {
        guard !isLoading else {
            Logger.warning("LoadUser blocked - already loading", category: .viewModel)
            return
        }
        
        performUserLoad()
    }
    
    func updateUser(name: String, email: String) async -> Bool {
        guard canUpdate else { return false }
        
        return await performUserUpdate(name: name, email: email)
    }
    
    func deleteUser() async -> Bool {
        guard canDelete else { return false }
        
        return await performUserDeletion()
    }
    
    func confirmDelete() {
        showDeleteConfirmation = true
    }
    
    func cancelDelete() {
        showDeleteConfirmation = false
    }
    
    func clearError() {
        error = nil
    }
    
    func retryLoadUser() {
        logRetryState()
        resetUserState()
        loadUser()
    }
}

private extension UserDetailViewModel {
    
    var canUpdate: Bool {
        !isUpdating && user != nil
    }
    
    var canDelete: Bool {
        !isDeleting && user != nil
    }
    
    func performUserLoad() {
        Logger.lifecycle("Starting load process for user \(userId)", component: "UserDetailViewModel")
        
        setupLoadingState()
        
        Task {
            await executeUserLoadAPI()
        }
    }
    
    func setupLoadingState() {
        isLoading = true
        error = nil
    }
    
    func executeUserLoadAPI() async {
        do {
            Logger.debug("Calling userService.getUser(id: \(userId))", category: .api)
            let fetchedUser = try await userService.getUser(id: userId)
            await handleLoadSuccess(fetchedUser)
            
        } catch {
            await handleLoadError(error)
        }
    }
    
    func handleLoadSuccess(_ fetchedUser: User) async {
        await MainActor.run {
            Logger.apiSuccess("User \(self.userId) loaded: \(fetchedUser.name)")
            self.user = fetchedUser
            self.isLoading = false
        }
    }
    
    func handleLoadError(_ error: Error) async {
        await MainActor.run {
            Logger.error("User \(self.userId) load failed: \(error)", category: .viewModel)
            self.error = error as? APIError ?? .unknown(Strings.CommonErrors.unknown)
            self.isLoading = false
        }
    }
}

private extension UserDetailViewModel {
    
    func performUserUpdate(name: String, email: String) async -> Bool {
        guard let currentUser = user else { return false }
        
        setupUpdateState()
        
        let updatedUser = createUpdatedUser(from: currentUser, name: name, email: email)
        let updateRequest = UpdateUserRequest(from: updatedUser)
        
        return await executeUpdateAPI(with: updateRequest)
    }
    
    func setupUpdateState() {
        isUpdating = true
        error = nil
    }
    
    func createUpdatedUser(from currentUser: User, name: String, email: String) -> User {
        return User(
            id: currentUser.id,
            name: name,
            username: currentUser.username,
            email: email,
            address: currentUser.address,
            phone: currentUser.phone,
            website: currentUser.website,
            company: currentUser.company
        )
    }
    
    func executeUpdateAPI(with request: UpdateUserRequest) async -> Bool {
        do {
            let result = try await userService.updateUser(id: userId, request)
            return await handleUpdateSuccess(result)
            
        } catch {
            return await handleUpdateError(error)
        }
    }
    
    func handleUpdateSuccess(_ updatedUser: User) async -> Bool {
        await MainActor.run {
            self.user = updatedUser
            self.isUpdating = false
        }
        return true
    }
    
    func handleUpdateError(_ error: Error) async -> Bool {
        await MainActor.run {
            self.error = error as? APIError ?? .unknown(Strings.CommonErrors.unknown)
            self.isUpdating = false
        }
        return false
    }
}

private extension UserDetailViewModel {
    
    func performUserDeletion() async -> Bool {
        guard let user = user else { return false }
        
        setupDeleteState()
        
        return await executeDeleteAPI(for: user)
    }
    
    func setupDeleteState() {
        isDeleting = true
        error = nil
    }
    
    func executeDeleteAPI(for user: User) async -> Bool {
        do {
            _ = try await userService.deleteUser(id: user.id)
            return await handleDeleteSuccess()
            
        } catch {
            return await handleDeleteError(error)
        }
    }
    
    func handleDeleteSuccess() async -> Bool {
        await MainActor.run {
            self.isDeleting = false
        }
        return true
    }
    
    func handleDeleteError(_ error: Error) async -> Bool {
        await MainActor.run {
            self.error = error as? APIError ?? .unknown(Strings.CommonErrors.unknown)
            self.isDeleting = false
        }
        return false
    }
}

private extension UserDetailViewModel {
    
    func logRetryState() {
        Logger.info("Starting retry process for user \(userId)", category: .viewModel)
        Logger.debug("Current state: user=\(user?.name ?? "nil"), isLoading=\(isLoading), hasError=\(error != nil)", category: .viewModel)
    }
    
    func resetUserState() {
        error = nil
        user = nil
        Logger.info("State reset - calling loadUser", category: .viewModel)
    }
}
