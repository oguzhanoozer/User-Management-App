//
//  NetworkModels.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation

protocol NetworkRequest {
    var endpoint: APIEndpoint { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

protocol NetworkResponse {
    associatedtype DataType: Codable
    var data: DataType? { get }
    var error: APIError? { get }
    var statusCode: Int { get }
}

struct DefaultNetworkResponse<T: Codable>: NetworkResponse {
    typealias DataType = T
    let data: T?
    let error: APIError?
    let statusCode: Int
}

enum APIError: Error, LocalizedError, Equatable {
    case invalidURL
    case noData
    case decodingError(String)
    case networkError(String)
    case serverError(Int, String)
    case timeoutError
    case noInternetConnection
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return Strings.Errors.invalidURL
        case .noData:
            return Strings.Errors.serverResponse
        case .decodingError(let message):
            return Strings.Errors.invalidURL
        case .networkError(let message):
            return Strings.Errors.general
        case .serverError(let code, let message):
            return Strings.Errors.serverError(code, message)
        case .timeoutError:
            return Strings.Errors.general
        case .noInternetConnection:
            return Strings.Errors.general
        case .unknown(let message):
            return Strings.Errors.general
        }
    }
    
    var isRecoverable: Bool {
        switch self {
        case .timeoutError, .noInternetConnection, .networkError:
            return true
        default:
            return false
        }
    }
}

struct GenericAPIRequest: NetworkRequest {
    let endpoint: APIEndpoint
    let method: HTTPMethod
    let parameters: [String: Any]?
    let headers: [String: String]?
    let body: Data?
    let id: Int?
    
    init(
        endpoint: APIEndpoint,
        method: HTTPMethod = .GET,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil,
        id: Int? = nil
    ) {
        self.endpoint = endpoint
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.body = body
        self.id = id
    }
    
    var fullURL: String {
        if let id = id {
            return endpoint.fullURLWithID(id)
        }
        return endpoint.fullURL
    }
}
