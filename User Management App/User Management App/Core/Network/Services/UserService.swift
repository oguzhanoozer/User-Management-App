//
//  UserService.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation
import Combine
import Alamofire

protocol UserServiceProtocol {
    func getUsers() async throws -> [User]
    func getUsers(page: Int, limit: Int) async throws -> [User]
    func getUser(id: Int) async throws -> User
    func realCreateUser(_ request: CreateUserRequest) async throws -> User
    func updateUser(id: Int, _ request: UpdateUserRequest) async throws -> User
    func deleteUser(id: Int) async throws -> DeleteUserResponse
}

class UserService: UserServiceProtocol {
    @Published private var apiUsers: [User] = []
    @Published private var localUsers: [User] = []
    @Published private var deletedUserIds: Set<Int> = []
    
    private let session: Session
    private var nextLocalId = 1000
    private var cancellables = Set<AnyCancellable>()
    private let useMockData: Bool
    
    var allUsers: [User] {
        let validApiUsers = apiUsers.filter { !deletedUserIds.contains($0.id) }
        return validApiUsers + localUsers
    }
    
    init() {
        self.useMockData = false
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConfiguration.timeoutInterval
        configuration.timeoutIntervalForResource = APIConfiguration.timeoutInterval
        self.session = Session(configuration: configuration)
    }
    
    func getUsers() async throws -> [User] {
        if apiUsers.isEmpty {
            await loadInitialData()
        }
        return allUsers
    }
    
    func getUsers(page: Int, limit: Int) async throws -> [User] {
        Logger.info("getUsers called", category: .api)
        Logger.debug("page: \(page), limit: \(limit), useMockData: \(useMockData)", category: .api)
        
        if useMockData {
            Logger.debug("Using mock data path", category: .api)
            await loadInitialData()
            let startIndex = (page - 1) * limit
            let endIndex = min(startIndex + limit, allUsers.count)
            guard startIndex < allUsers.count else { return [] }
            return Array(allUsers[startIndex..<endIndex])
        } else {
            Logger.debug("Using real API path - calling realGetUsers", category: .api)
            return try await realGetUsers(page: page, limit: limit)
        }
    }
    
    func getUser(id: Int) async throws -> User {
        if let user = allUsers.first(where: { $0.id == id }) {
            return user
        }
        
        if !deletedUserIds.contains(id) {
            if useMockData {
                if id <= 10 {
                    return try await getMockUser(id: id)
                }
            } else {
                return try await getRealUser(id: id)
            }
        }
        
        throw APIError.serverError(404, Strings.CommonErrors.userNotFound)
    }
    
    func updateUser(id: Int, _ request: UpdateUserRequest) async throws -> User {
        Logger.info("updateUser called for id: \(id)", category: .api)
        
        let createRequest = CreateUserRequest(
            name: request.name,
            username: request.username,
            email: request.email,
            address: request.address,
            phone: request.phone,
            website: request.website,
            company: request.company
        )
        let updatedUser = User.fromRequest(createRequest, id: id)
        
        do {
            if useMockData {
                Logger.debug("Using mock update", category: .api)
                try await mockUpdateUser(id: id, request)
            } else {
                Logger.debug("Calling real API update", category: .api)
                try await realUpdateUser(id: id, request)
            }
            Logger.apiSuccess("User update successful", endpoint: "updateUser")
        } catch {
            Logger.apiError(error, endpoint: "updateUser")
            throw error
        }
        
        await MainActor.run {
            if let index = self.apiUsers.firstIndex(where: { $0.id == id }) {
                self.apiUsers[index] = updatedUser
            } else if let index = self.localUsers.firstIndex(where: { $0.id == id }) {
                self.localUsers[index] = updatedUser
            }
        }
        
        return updatedUser
    }
    
    func deleteUser(id: Int) async throws -> DeleteUserResponse {
        Logger.info("deleteUser called for id: \(id)", category: .api)
        
        do {
            if useMockData {
                Logger.debug("Using mock delete", category: .api)
                try await mockDeleteUser(id: id)
            } else {
                Logger.debug("Calling real API delete", category: .api)
                try await realDeleteUser(id: id)
            }
            Logger.apiSuccess("User delete successful", endpoint: "deleteUser")
        } catch {
            Logger.apiError(error, endpoint: "deleteUser")
            throw error
        }
        
        await MainActor.run {
            if self.apiUsers.contains(where: { $0.id == id }) {
                self.deletedUserIds.insert(id)
            }
            self.localUsers.removeAll { $0.id == id }
        }
        
        return DeleteUserResponse.success
    }
    
    @MainActor
    private func loadInitialData() async {
        do {
            if useMockData {
                self.apiUsers = User.mockUsers
                try await Task.sleep(nanoseconds: 500_000_000)
            } else {
                let users = try await realGetUsers()
                self.apiUsers = users
            }
        } catch {
            Logger.error("Failed to load initial data: \(error)", category: .api)
        }
    }
}

extension UserService {
    
    private func realGetUsers() async throws -> [User] {
        let url = APIConfiguration.baseURL + APIEndpoint.users.path
        
        return try await withRetry(maxAttempts: 3, delay: 1.0) {
            return try await withCheckedThrowingContinuation { continuation in
                self.session.request(url, method: .get)
                    .validate()
                    .responseDecodable(of: [User].self) { response in
                        switch response.result {
                        case .success(let users):
                            continuation.resume(returning: users)
                        case .failure(let error):
                            continuation.resume(throwing: self.mapError(error))
                        }
                    }
            }
        }
    }
    
    private func realGetUsers(page: Int, limit: Int) async throws -> [User] {
        Logger.debug("realGetUsers called - page: \(page), limit: \(limit)", category: .api)
        
        let url =  APIConfiguration.baseURL + APIEndpoint.users.path
        let parameters: [String: Any] = [
            "_page": page,
            "_limit": limit
        ]
        
        
        Logger.networkRequest(method: "GET", url: "\(url)?_page=\(page)&_limit=\(limit)")
        
        return try await withRetry(maxAttempts: 3, delay: 1.0) {
            return try await withCheckedThrowingContinuation { continuation in
                self.session.request(url, method: .get, parameters: parameters)
                    .validate()
                    .responseDecodable(of: [User].self) { response in
                        switch response.result {
                        case .success(let users):
                            Logger.networkResponse(url: url, statusCode: 200)
                            Logger.dataFlow("Received users for page \(page)", count: users.count)
                            continuation.resume(returning: users)
                        case .failure(let error):
                            Logger.networkResponse(url: url, statusCode: 500)
                            Logger.apiError(error, endpoint: "getUsers")
                            continuation.resume(throwing: self.mapError(error))
                        }
                    }
            }
        }
    }
    
    private func getRealUser(id: Int) async throws -> User {
        let url = APIConfiguration.baseURL + APIEndpoint.user.pathWithID(id)
        
        return try await withRetry(maxAttempts: 3, delay: 1.0) {
            return try await withCheckedThrowingContinuation { continuation in
                self.session.request(url, method: .get)
                    .validate()
                    .responseDecodable(of: User.self) { response in
                        switch response.result {
                        case .success(let user):
                            continuation.resume(returning: user)
                        case .failure(let error):
                            continuation.resume(throwing: self.mapError(error))
                        }
                    }
            }
        }
    }
    
    private func getMockUser(id: Int) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        guard let user = User.mockUsers.first(where: { $0.id == id }) else {
            throw APIError.serverError(404, Strings.CommonErrors.userNotFound)
        }
        return user
    }
    
    func realCreateUser(_ request: CreateUserRequest) async throws -> User {
        let url = APIConfiguration.baseURL + APIEndpoint.users.path
        let parameters = try request.asDictionary()
        
        let response = try await withRetry(maxAttempts: 3, delay: 1.0) {
            return try await withCheckedThrowingContinuation { continuation in
                self.session.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                    .validate()
                    .responseDecodable(of: CreateUserResponse.self) { response in
                        switch response.result {
                        case .success(let createResponse):
                            continuation.resume(returning: createResponse)
                        case .failure(let error):
                            continuation.resume(throwing: self.mapError(error))
                        }
                    }
            }
        }
        
        let createdUser = User.fromRequest(request, id: response.id)
        return createdUser
    }
    
    private func mockCreateUser(_ request: CreateUserRequest) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func realUpdateUser(id: Int, _ request: UpdateUserRequest) async throws {
        let url = APIConfiguration.baseURL + APIEndpoint.user.pathWithID(id)
        let parameters = try request.asDictionary()
        
        return try await withRetry(maxAttempts: 3, delay: 1.0) {
            return try await withCheckedThrowingContinuation { continuation in
                self.session.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default)
                    .validate()
                    .response { response in
                        switch response.result {
                        case .success:
                            continuation.resume()
                        case .failure(let error):
                            continuation.resume(throwing: self.mapError(error))
                        }
                    }
            }
        }
    }
    
    private func mockUpdateUser(id: Int, _ request: UpdateUserRequest) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func realDeleteUser(id: Int) async throws {
        let url = APIConfiguration.baseURL + APIEndpoint.user.pathWithID(id)
        
        return try await withRetry(maxAttempts: 3, delay: 1.0) {
            return try await withCheckedThrowingContinuation { continuation in
                self.session.request(url, method: .delete)
                    .validate()
                    .response { response in
                        switch response.result {
                        case .success:
                            continuation.resume()
                        case .failure(let error):
                            continuation.resume(throwing: self.mapError(error))
                        }
                    }
            }
        }
    }
    
    private func mockDeleteUser(id: Int) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func withRetry<T>(
        maxAttempts: Int,
        delay: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...maxAttempts {
            do {
                Logger.retry("Network operation", attempt: attempt, maxAttempts: maxAttempts)
                let result = try await operation()
                if attempt > 1 {
                    Logger.info("Retry succeeded on attempt \(attempt)", category: .network)
                }
                return result
            } catch {
                lastError = error
                
                if attempt < maxAttempts {
                    let retryDelay = delay * Double(attempt)
                    Logger.info("Retrying in \(retryDelay) seconds...", category: .network)
                    try await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
                }
            }
        }
        
        Logger.error("All retry attempts failed", category: .network)
        throw lastError ?? APIError.unknown("All retry attempts failed")
    }
    
    private nonisolated func mapError(_ error: AFError) -> APIError {
        switch error {
        case .invalidURL:
            return .invalidURL
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let code):
                let message = HTTPURLResponse.localizedString(forStatusCode: code)
                return .serverError(code, message)
            default:
                return .networkError(Strings.CommonErrors.invalidResponse)
            }
        case .responseSerializationFailed(let reason):
            switch reason {
            case .decodingFailed(_):
                return .decodingError(Strings.CommonErrors.decodingFailed)
            default:
                return .decodingError(Strings.CommonErrors.decodingFailed)
            }
        case .sessionTaskFailed(let sessionError):
            if let urlError = sessionError as? URLError {
                switch urlError.code {
                case .timedOut:
                    return .timeoutError
                case .notConnectedToInternet, .networkConnectionLost:
                    return .noInternetConnection
                default:
                    return .networkError(Strings.CommonErrors.networkTimeout)
                }
            }
            return .networkError(Strings.CommonErrors.networkTimeout)
        default:
            return .unknown(Strings.CommonErrors.unknown)
        }
    }
}
