//
//  UserDetailViewModel.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation
import Combine

@MainActor
class UserDetailViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var isDeleting = false
    @Published var isUpdating = false
    @Published var showDeleteConfirmation = false
    
    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let userId: Int
    
    var hasError: Bool {
        error != nil
    }
    
    var errorMessage: String {
        error?.errorDescription ?? "Unknown error"
    }
    
    var canPerformActions: Bool {
        !isLoading && !isDeleting && !isUpdating
    }
    
    init(
        userId: Int,
        userService: UserServiceProtocol = ServiceLocator.shared.resolve(UserServiceProtocol.self)
    ) {
        self.userId = userId
        self.userService = userService
    }
    
    func loadUser() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let fetchedUser = try await userService.getUser(id: userId)
                await MainActor.run {
                    self.user = fetchedUser
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
    
    func updateUser(_ updatedUser: User) {
        guard !isUpdating else { return }
        
        isUpdating = true
        error = nil
        
        let updateRequest = UpdateUserRequest(from: updatedUser)
        
        Task {
            do {
                let result = try await userService.updateUser(id: userId, updateRequest)
                await MainActor.run {
                    self.user = result
                    self.isUpdating = false
                }
            } catch {
                await MainActor.run {
                    self.error = error as? APIError ?? .unknown(error.localizedDescription)
                    self.isUpdating = false
                }
            }
        }
    }
    
    func deleteUser() -> Bool {
        guard !isDeleting, let user = user else { return false }
        
        isDeleting = true
        error = nil
        
        Task {
            do {
                _ = try await userService.deleteUser(id: user.id)
                await MainActor.run {
                    self.isDeleting = false
                }
            } catch {
                await MainActor.run {
                    self.error = error as? APIError ?? .unknown(error.localizedDescription)
                    self.isDeleting = false
                }
            }
        }
        
        return true
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
        loadUser()
    }
}

extension UserDetailViewModel {
    func loadUserWithPublisher() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        userService.getUserPublisher(id: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<APIError>) in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] user in
                    self?.user = user
                }
            )
            .store(in: &cancellables)
    }
}