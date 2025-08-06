//
//  APIConfiguration.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation

struct APIConfiguration {
    static let baseURL = "https://jsonplaceholder.typicode.com"
    static let timeoutInterval: TimeInterval = 30.0
}

enum APIEndpoint: String, CaseIterable {
    case users = "/users"
    case user = "/users/{id}"
    
    var path: String {
        return self.rawValue
    }
    
    func pathWithID(_ id: Int) -> String {
        return path.replacingOccurrences(of: "{id}", with: "\(id)")
    }
    
    var fullURL: String {
        return APIConfiguration.baseURL + path
    }
    
    func fullURLWithID(_ id: Int) -> String {
        return APIConfiguration.baseURL + pathWithID(id)
    }
}

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

struct HTTPHeaders {
    static let contentType = "Content-Type"
    static let accept = "Accept"
    static let authorization = "Authorization"
    
    static let applicationJSON = "application/json"
    static let applicationFormUrlencoded = "application/x-www-form-urlencoded"
    
    static var defaultHeaders: [String: String] {
        return [
            contentType: applicationJSON,
            accept: applicationJSON
        ]
    }
}
