//
//  UserListViewModel.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation
import Combine

@MainActor
class UserListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var searchText = ""
    @Published var isRefreshing = false
    
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var paginationManager = PaginationManager<User>(pageSize: 5)
    @Published var infiniteScrollManager = InfiniteScrollManager<User>(pageSize: 10)
    @Published var usePagination = true
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        }
        return users.filter { user in
            user.name.localizedCaseInsensitiveContains(searchText) ||
            user.email.localizedCaseInsensitiveContains(searchText) ||
            user.username.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var displayUsers: [User] {
        let filtered = filteredUsers
        if usePagination {
            paginationManager.updateItems(filtered)
            return paginationManager.currentPageItems
        } else {
            infiniteScrollManager.updateAllItems(filtered)
            return infiniteScrollManager.displayedItems
        }
    }
    
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String {
        error?.errorDescription ?? "Unknown error"
    }
    
    init(userService: UserServiceProtocol = ServiceLocator.shared.resolve(UserServiceProtocol.self)) {
        self.userService = userService
    }
    
    func loadUsers() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let fetchedUsers = try await userService.getUsers()
                await MainActor.run {
                    self.users = fetchedUsers
                    self.updatePagination()
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
    
    func refreshUsers() {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        error = nil
        
        Task {
            do {
                let fetchedUsers = try await userService.getUsers()
                await MainActor.run {
                    self.users = fetchedUsers
                    self.updatePagination()
                    self.isRefreshing = false
                }
            } catch {
                await MainActor.run {
                    self.error = error as? APIError ?? .unknown(error.localizedDescription)
                    self.isRefreshing = false
                }
            }
        }
    }
    
    func deleteUser(_ user: User) {
        Task {
            do {
                _ = try await userService.deleteUser(id: user.id)
                await MainActor.run {
                    self.users.removeAll { $0.id == user.id }
                    self.updatePagination()
                }
            } catch {
                await MainActor.run {
                    self.error = error as? APIError ?? .unknown(error.localizedDescription)
                }
            }
        }
    }
    
    func clearError() {
        error = nil
    }
    
    func retryLoadUsers() {
        loadUsers()
    }
    
    func addUser(_ user: User) {
        users.append(user)
        updatePagination()
    }
    
    func updateUser(_ updatedUser: User) {
        if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
            users[index] = updatedUser
            updatePagination()
        }
    }
    
    func togglePaginationMode() {
        usePagination.toggle()
        updatePagination()
    }
    
    private func updatePagination() {
        let filtered = filteredUsers
        if usePagination {
            paginationManager.updateItems(filtered)
        } else {
            infiniteScrollManager.updateAllItems(filtered)
        }
    }
    
    func searchTextChanged() {
        updatePagination()
    }
    
    func loadMoreIfNeeded(for user: User) {
        if !usePagination && infiniteScrollManager.shouldLoadMore(currentItem: user) {
            infiniteScrollManager.loadNextBatch()
        }
    }
}

extension UserListViewModel {
    func loadUsersWithPublisher() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        userService.getUsersPublisher()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] users in
                    self?.users = users
                    self?.updatePagination()
                }
            )
            .store(in: &cancellables)
    }
}