//
//  APIError+Extensions.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation

extension APIError {
    static func localizedMessage(from error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .invalidURL:
                return Strings.Errors.invalidURL
            case .noData:
                return Strings.Errors.serverResponse
            case .decodingError:
                return Strings.Errors.invalidURL
            case .networkError:
                return Strings.Errors.general
            case .serverError(let code, let message):
                return Strings.Errors.serverError(code, message)
            case .unknown:
                return Strings.Errors.general
            case .timeoutError:
                return Strings.Errors.general
            case .noInternetConnection:
                return Strings.Errors.general
            }
        } else {
            return Strings.Errors.general
        }
    }
}
