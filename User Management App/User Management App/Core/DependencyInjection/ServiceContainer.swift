//
//  ServiceContainer.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation

protocol ServiceContainerProtocol {
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func resolve<T>(_ type: T.Type) -> T
}

class ServiceContainer: ServiceContainerProtocol {
    static let shared = ServiceContainer()
    
    private var services: [String: Any] = [:]
    private var factories: [String: () -> Any] = [:]
    
    private init() {}
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        if let service = services[key] as? T {
            return service
        }
        
        guard let factory = factories[key] else {
            fatalError("Service of type \(type) is not registered")
        }
        
        let service = factory() as! T
        services[key] = service
        return service
    }
    
    func registerSingleton<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
    }
    
    func clear() {
        services.removeAll()
        factories.removeAll()
    }
}

class ServiceLocator {
    static let shared = ServiceLocator()
    private let container = ServiceContainer.shared
    
    private init() {
        setupServices()
    }
    
    private func setupServices() {
        registerUserService()
    }
    
    private func registerUserService() {
        container.register(UserServiceProtocol.self) {
            UserService()
        }
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        return container.resolve(type)
    }
    
    func switchToMock() {
        AppConfiguration.switchToMock()
        container.clear()
        setupServices()
    }
    
    func switchToReal() {
        AppConfiguration.switchToReal()
        container.clear()
        setupServices()
    }
}

struct AppConfiguration {
    private static var _useMockServices: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    static var useMockServices: Bool {
        return _useMockServices
    }
    
    static func switchToMock() {
        _useMockServices = true
    }
    
    static func switchToReal() {
        _useMockServices = false
    }
}