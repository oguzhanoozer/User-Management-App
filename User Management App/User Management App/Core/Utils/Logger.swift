//
//  Logger.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation
import os.log

struct AppLogger {
    
    enum LogLevel: String, CaseIterable {
        case debug = "🔍 DEBUG"
        case info = "ℹ️ INFO"
        case warning = "⚠️ WARNING"
        case error = "❌ ERROR"
        case critical = "🚨 CRITICAL"
        
        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
            }
        }
    }
    
    enum Category: String, CaseIterable {
        case network = "NETWORK"
        case ui = "UI"
        case viewModel = "VIEWMODEL"
        case userAction = "USER_ACTION"
        case api = "API"
        case dataFlow = "DATA_FLOW"
        case error = "ERROR"
        case lifecycle = "LIFECYCLE"
        case performance = "PERFORMANCE"
        
        var emoji: String {
            switch self {
            case .network: return "🌐"
            case .ui: return "📱"
            case .viewModel: return "🧠"
            case .userAction: return "👆"
            case .api: return "🔄"
            case .dataFlow: return "📊"
            case .error: return "💥"
            case .lifecycle: return "♻️"
            case .performance: return "⚡"
            }
        }
        
        var osLog: OSLog {
            return OSLog(subsystem: "com.userapp.logging", category: self.rawValue)
        }
    }
    
    private static var isEnabled: Bool = true
    private static var minimumLogLevel: LogLevel = .debug
        
    static func debug(_ message: String, category: Category = .ui, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    static func info(_ message: String, category: Category = .ui, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    static func warning(_ message: String, category: Category = .error, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, category: Category = .error, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
    
    static func critical(_ message: String, category: Category = .error, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, category: category, file: file, function: function, line: line)
    }
    
    
    static func networkRequest(method: String, url: String, parameters: [String: Any]? = nil) {
        var message = "\(method) \(url)"
        if let params = parameters, !params.isEmpty {
            message += " with parameters: \(params)"
        }
        log(message, level: .info, category: .network)
    }
    
    static func networkResponse(url: String, statusCode: Int, responseTime: TimeInterval? = nil) {
        var message = "Response from \(url) - Status: \(statusCode)"
        if let time = responseTime {
            message += " (\(String(format: "%.2f", time))s)"
        }
        let level: LogLevel = (200...299).contains(statusCode) ? .info : .error
        log(message, level: level, category: .network)
    }
    
    static func apiError(_ error: Error, endpoint: String? = nil) {
        var message = "API Error"
        if let endpoint = endpoint {
            message += " at \(endpoint)"
        }
        message += ": \(error.localizedDescription)"
        log(message, level: .error, category: .api)
    }
    
    static func userAction(_ action: String, details: String? = nil) {
        var message = "User Action: \(action)"
        if let details = details {
            message += " - \(details)"
        }
        log(message, level: .info, category: .userAction)
    }
    
    static func dataFlow(_ event: String, count: Int? = nil) {
        var message = "Data Flow: \(event)"
        if let count = count {
            message += " (count: \(count))"
        }
        log(message, level: .info, category: .dataFlow)
    }
    
    static func viewModelState<T>(_ viewModel: String, state: String, value: T) {
        let message = "\(viewModel) - \(state): \(value)"
        log(message, level: .debug, category: .viewModel)
    }
    
    static func performance(_ operation: String, duration: TimeInterval) {
        let message = "Performance: \(operation) took \(String(format: "%.3f", duration))s"
        let level: LogLevel = duration > 1.0 ? .warning : .info
        log(message, level: level, category: .performance)
    }
    
    static func lifecycle(_ event: String, component: String) {
        let message = "\(component) - \(event)"
        log(message, level: .info, category: .lifecycle)
    }
    
    
    static func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
    
    static func setMinimumLogLevel(_ level: LogLevel) {
        minimumLogLevel = level
    }
    
    
    private static func log(_ message: String, level: LogLevel, category: Category, file: String = #file, function: String = #function, line: Int = #line) {
        guard isEnabled && shouldLog(level: level) else { return }
        
        let fileName = (file as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        let timestamp = dateFormatter.string(from: Date())
        
        let logMessage = "[\(timestamp)] \(level.rawValue) \(category.emoji) \(category.rawValue) | \(fileName).\(function):\(line) | \(message)"
        
        print(logMessage)
        
        os_log("%{public}@", log: category.osLog, type: level.osLogType, logMessage)
    }
    
    private static func shouldLog(level: LogLevel) -> Bool {
        let levels: [LogLevel] = [.debug, .info, .warning, .error, .critical]
        guard let currentIndex = levels.firstIndex(of: level),
              let minimumIndex = levels.firstIndex(of: minimumLogLevel) else {
            return true
        }
        return currentIndex >= minimumIndex
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}


extension AppLogger {
    
    static func error(_ error: Error, category: Category = .error, file: String = #file, function: String = #function, line: Int = #line) {
        log("Error: \(error.localizedDescription)", level: .error, category: category, file: file, function: function, line: line)
    }
    
    static func apiSuccess(_ message: String, endpoint: String? = nil) {
        var fullMessage = "API Success: \(message)"
        if let endpoint = endpoint {
            fullMessage += " at \(endpoint)"
        }
        log(fullMessage, level: .info, category: .api)
    }
    
    static func loadingState(_ isLoading: Bool, component: String) {
        let state = isLoading ? "Started" : "Finished"
        let message = "\(component) - Loading \(state)"
        log(message, level: .debug, category: .ui)
    }
    
    static func retry(_ operation: String, attempt: Int, maxAttempts: Int) {
        let message = "Retry: \(operation) - Attempt \(attempt)/\(maxAttempts)"
        log(message, level: .info, category: .network)
    }
}

typealias Logger = AppLogger
