//
//  UserListViewModel.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation

@MainActor
class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var isRefreshing = false
    @Published var currentPage = 1
    @Published var isLoadingPage = false
    @Published var hasMorePages = true
    
    private let pageSize = 5
    private let userService: UserServiceProtocol
    
    var filteredUsers: [User] {
        return users
    }
    
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String {
        if let error = error {
            return APIError.localizedMessage(from: error)
        }
        return Strings.CommonErrors.unknown
    }
    
    init() {
        self.userService = UserService()
    }
    
    func loadUsers() {
        print("📱 LOAD USERS - Starting load process...")
        loadUsersPage(page: 1, isRefresh: true)
    }
    
    func loadNextPage() {
        guard hasMorePages && !isLoadingPage else { return }
        loadUsersPage(page: currentPage + 1)
    }
    
    func refreshUsers() {
        guard !isRefreshing else { return }
        performRefresh()
    }
    
    func retryLoadUsers() {
        logRetryState()
        resetState()
        loadUsers()
    }
    
    func deleteUser(_ user: User) {
        performDeleteUser(user)
    }
    
    func addUser(_ user: User) {
        users.append(user)
    }
    
    func updateUser(_ updatedUser: User) {
        if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
            users[index] = updatedUser
        }
    }
    
    func clearError() {
        error = nil
    }
}

private extension UserListViewModel {
    
    func loadUsersPage(page: Int, isRefresh: Bool = false) {
        guard !isLoading && !isLoadingPage else {
            print("⚠️ LoadUsersPage blocked - isLoading=\(isLoading), isLoadingPage=\(isLoadingPage)")
            return
        }
        
        print("📄 LOAD USERS PAGE \(page) - isRefresh=\(isRefresh)")
        
        setupLoadingState(for: page, isRefresh: isRefresh)
        
        Task {
            await performAPICall(for: page, isRefresh: isRefresh)
        }
    }
    
    func setupLoadingState(for page: Int, isRefresh: Bool) {
        if isRefresh {
            isLoading = true
            currentPage = 1
            users = []
            hasMorePages = true
            error = nil
        } else {
            isLoadingPage = true
        }
    }
    
    func performAPICall(for page: Int, isRefresh: Bool) async {
        do {
            print("📄 Loading page \(page) with \(pageSize) users per page...")
            let fetchedUsers = try await userService.getUsers(page: page, limit: pageSize)
            
            print("🎉 API SUCCESS - Received \(fetchedUsers.count) users")
            
            await handleSuccessResponse(fetchedUsers, for: page, isRefresh: isRefresh)
            
        } catch {
            print("💥 API ERROR: \(error)")
            await handleErrorResponse(error, for: page)
        }
    }
    
    func handleSuccessResponse(_ fetchedUsers: [User], for page: Int, isRefresh: Bool) async {
        await MainActor.run {
            self.error = nil
            
            if isRefresh {
                self.users = fetchedUsers
            } else {
                self.users.append(contentsOf: fetchedUsers)
            }
            
            self.currentPage = page
            self.hasMorePages = fetchedUsers.count == self.pageSize
            self.isLoading = false
            self.isLoadingPage = false
            
            print("✅ Page \(page) loaded: \(fetchedUsers.count) users")
            print("📊 Total users: \(self.users.count)")
        }
    }
    
    func handleErrorResponse(_ error: Error, for page: Int) async {
        await MainActor.run {
            self.error = error as? APIError ?? .unknown(Strings.CommonErrors.unknown)
            self.isLoading = false
            self.isLoadingPage = false
            print("❌ Failed to load page \(page): \(error)")
        }
    }
    
    func performRefresh() {
        isRefreshing = true
        error = nil
        
        print("🔄 Refreshing users - loading first page...")
        
        Task {
            do {
                print("📄 Refresh: Loading page 1 with \(pageSize) users per page...")
                let fetchedUsers = try await userService.getUsers(page: 1, limit: pageSize)
                
                await handleRefreshSuccess(fetchedUsers)
                
            } catch {
                await handleRefreshError(error)
            }
        }
    }
    
    func handleRefreshSuccess(_ fetchedUsers: [User]) async {
        await MainActor.run {
            self.error = nil
            self.users = fetchedUsers
            self.currentPage = 1
            self.hasMorePages = fetchedUsers.count == self.pageSize
            self.isRefreshing = false
            
            print("✅ Refresh completed: \(fetchedUsers.count) users")
            print("📊 Total users after refresh: \(self.users.count)")
        }
    }
    
    func handleRefreshError(_ error: Error) async {
        await MainActor.run {
            self.error = error as? APIError ?? .unknown(Strings.CommonErrors.unknown)
            self.isRefreshing = false
            print("❌ Failed to refresh: \(error)")
        }
    }
    
    func performDeleteUser(_ user: User) {
        Task {
            do {
                _ = try await userService.deleteUser(id: user.id)
                await MainActor.run {
                    self.users.removeAll { $0.id == user.id }
                }
            } catch {
                await MainActor.run {
                    self.error = error as? APIError ?? .unknown(Strings.CommonErrors.unknown)
                }
            }
        }
    }
    
    func logRetryState() {
        print("🔄 RETRY USERS - Starting retry process...")
        print("🔄 Current state before retry:")
        print("   - users.count: \(users.count)")
        print("   - isLoading: \(isLoading)")
        print("   - hasError: \(error != nil)")
        print("   - error: \(String(describing: error))")
    }
    
    func resetState() {
        error = nil
        users = []
        currentPage = 1
        hasMorePages = true
        isLoadingPage = false
        isRefreshing = false
        isLoading = false
        
        print("🔄 State cleared - New state:")
        print("   - users.count: \(users.count)")
        print("   - isLoading: \(isLoading)")
        print("   - hasError: \(error != nil)")
        print("   - error: \(String(describing: error))")
        
        print("🔄 Calling loadUsers()...")
    }
}
