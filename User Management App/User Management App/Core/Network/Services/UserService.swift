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
    func getUser(id: Int) async throws -> User
    func createUser(_ request: CreateUserRequest) async throws -> User
    func updateUser(id: Int, _ request: UpdateUserRequest) async throws -> User
    func deleteUser(id: Int) async throws -> DeleteUserResponse
    
    func getUsersPublisher() -> AnyPublisher<[User], APIError>
    func getUserPublisher(id: Int) -> AnyPublisher<User, APIError>
    func createUserPublisher(_ request: CreateUserRequest) -> AnyPublisher<User, APIError>
    func updateUserPublisher(id: Int, _ request: UpdateUserRequest) -> AnyPublisher<User, APIError>
    func deleteUserPublisher(id: Int) -> AnyPublisher<DeleteUserResponse, APIError>
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
        #if DEBUG
        self.useMockData = AppConfiguration.useMockServices
        #else
        self.useMockData = false
        #endif
        
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
    
    func getUser(id: Int) async throws -> User {
        if let user = allUsers.first(where: { $0.id == id }) {
            return user
        }
        
        if !deletedUserIds.contains(id) && id <= 10 {
            if useMockData {
                return try await getMockUser(id: id)
            } else {
                return try await getRealUser(id: id)
            }
        }
        
        throw APIError.serverError(404, "User not found")
    }
    
    func createUser(_ request: CreateUserRequest) async throws -> User {
        let optimisticUser = User.fromRequest(request, id: nextLocalId)
        
        nextLocalId += 1
        localUsers.append(optimisticUser)
        
        Task {
            do {
                if useMockData {
                    try await mockCreateUser(request)
                } else {
                    try await realCreateUser(request)
                }
            } catch {
                await MainActor.run {
                    self.localUsers.removeAll { $0.id == optimisticUser.id }
                }
            }
        }
        
        return optimisticUser
    }
    
    func updateUser(id: Int, _ request: UpdateUserRequest) async throws -> User {
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
        
        if let index = apiUsers.firstIndex(where: { $0.id == id }) {
            apiUsers[index] = updatedUser
        } else if let index = localUsers.firstIndex(where: { $0.id == id }) {
            localUsers[index] = updatedUser
        }
        
        Task {
            do {
                if useMockData {
                    try await mockUpdateUser(id: id, request)
                } else {
                    try await realUpdateUser(id: id, request)
                }
            } catch {
                print("Update failed: \(error)")
            }
        }
        
        return updatedUser
    }
    
    func deleteUser(id: Int) async throws -> DeleteUserResponse {
        if apiUsers.contains(where: { $0.id == id }) {
            deletedUserIds.insert(id)
        }
        
        localUsers.removeAll { $0.id == id }
        
        Task {
            do {
                if useMockData {
                    try await mockDeleteUser(id: id)
                } else {
                    try await realDeleteUser(id: id)
                }
            } catch {
                print("Delete failed: \(error)")
            }
        }
        
        return DeleteUserResponse.success
    }
    
    func getUsersPublisher() -> AnyPublisher<[User], APIError> {
        if apiUsers.isEmpty {
            Task { await loadInitialData() }
        }
        
        return Publishers.CombineLatest3($apiUsers, $localUsers, $deletedUserIds)
            .map { apiUsers, localUsers, deletedIds in
                let validApiUsers = apiUsers.filter { !deletedIds.contains($0.id) }
                return validApiUsers + localUsers
            }
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
    
    func getUserPublisher(id: Int) -> AnyPublisher<User, APIError> {
        return getUsersPublisher()
            .compactMap { users in
                users.first { $0.id == id }
            }
            .first()
            .eraseToAnyPublisher()
    }
    
    func createUserPublisher(_ request: CreateUserRequest) -> AnyPublisher<User, APIError> {
        return Future { promise in
            Task {
                do {
                    let user = try await self.createUser(request)
                    promise(.success(user))
                } catch {
                    promise(.failure(error as? APIError ?? .unknown(error.localizedDescription)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateUserPublisher(id: Int, _ request: UpdateUserRequest) -> AnyPublisher<User, APIError> {
        return Future { promise in
            Task {
                do {
                    let user = try await self.updateUser(id: id, request)
                    promise(.success(user))
                } catch {
                    promise(.failure(error as? APIError ?? .unknown(error.localizedDescription)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteUserPublisher(id: Int) -> AnyPublisher<DeleteUserResponse, APIError> {
        return Future { promise in
            Task {
                do {
                    let response = try await self.deleteUser(id: id)
                    promise(.success(response))
                } catch {
                    promise(.failure(error as? APIError ?? .unknown(error.localizedDescription)))
                }
            }
        }
        .eraseToAnyPublisher()
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
            print("Failed to load initial data: \(error)")
        }
    }
}

extension UserService {
    func reset() {
        apiUsers = []
        localUsers = []
        deletedUserIds = []
        nextLocalId = 1000
    }
    
    func getLocalUsersCount() -> Int {
        return localUsers.count
    }
    
    func getDeletedUsersCount() -> Int {
        return deletedUserIds.count
    }
    
    private func realGetUsers() async throws -> [User] {
        let url = APIConfiguration.baseURL + APIEndpoint.users.path
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get)
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
    
    private func getRealUser(id: Int) async throws -> User {
        let url = APIConfiguration.baseURL + APIEndpoint.user.pathWithID(id)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .get)
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
    
    private func getMockUser(id: Int) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        guard let user = User.mockUsers.first(where: { $0.id == id }) else {
            throw APIError.serverError(404, "User not found")
        }
        return user
    }
    
    private func realCreateUser(_ request: CreateUserRequest) async throws {
        let url = APIConfiguration.baseURL + APIEndpoint.users.path
        let parameters = try request.asDictionary()
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
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
    
    private func mockCreateUser(_ request: CreateUserRequest) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func realUpdateUser(id: Int, _ request: UpdateUserRequest) async throws {
        let url = APIConfiguration.baseURL + APIEndpoint.user.pathWithID(id)
        let parameters = try request.asDictionary()
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default)
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
    
    private func mockUpdateUser(id: Int, _ request: UpdateUserRequest) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func realDeleteUser(id: Int) async throws {
        let url = APIConfiguration.baseURL + APIEndpoint.user.pathWithID(id)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: .delete)
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
    
    private func mockDeleteUser(id: Int) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
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
                return .networkError(error.localizedDescription)
            }
        case .responseSerializationFailed(let reason):
            switch reason {
            case .decodingFailed(let decodingError):
                return .decodingError(decodingError.localizedDescription)
            default:
                return .decodingError(error.localizedDescription)
            }
        case .sessionTaskFailed(let sessionError):
            if let urlError = sessionError as? URLError {
                switch urlError.code {
                case .timedOut:
                    return .timeoutError
                case .notConnectedToInternet, .networkConnectionLost:
                    return .noInternetConnection
                default:
                    return .networkError(urlError.localizedDescription)
                }
            }
            return .networkError(sessionError.localizedDescription)
        default:
            return .unknown(error.localizedDescription)
        }
    }
}