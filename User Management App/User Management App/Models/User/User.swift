//
//  User.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation

struct User: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company
    
    var initials: String {
        let nameComponents = name.components(separatedBy: " ")
        let firstInitial = nameComponents.first?.first ?? Character("")
        let lastInitial = nameComponents.count > 1 ? nameComponents.last?.first ?? Character("") : Character("")
        return "\(firstInitial)\(lastInitial)".uppercased()
    }
    
    var fullAddress: String {
        return "\(address.street), \(address.suite), \(address.city) \(address.zipcode)"
    }
    
    var displayRole: String {
        return company.name
    }
    
    var memberSince: String {
        return "Member since 2019"
    }
}

struct Address: Codable, Equatable, Hashable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: Geo
    
    var shortAddress: String {
        return "\(city), \(zipcode)"
    }
}

struct Geo: Codable, Equatable, Hashable {
    let lat: String
    let lng: String
    
    var latitude: Double? {
        return Double(lat)
    }
    
    var longitude: Double? {
        return Double(lng)
    }
}

struct Company: Codable, Equatable, Hashable {
    let name: String
    let catchPhrase: String
    let bs: String
    
    var description: String {
        return catchPhrase
    }
    
    var businessType: String {
        return bs.capitalized
    }
}

extension User {
    static func fromRequest(_ request: CreateUserRequest, id: Int) -> User {
        return User(
            id: id,
            name: request.name,
            username: request.username,
            email: request.email,
            address: Address(
                street: request.address.street,
                suite: request.address.suite,
                city: request.address.city,
                zipcode: request.address.zipcode,
                geo: Geo(lat: request.address.geo.lat, lng: request.address.geo.lng)
            ),
            phone: request.phone,
            website: request.website,
            company: Company(
                name: request.company.name,
                catchPhrase: request.company.catchPhrase,
                bs: request.company.bs
            )
        )
    }
    
    static let mockUser = User(
        id: 1,
        name: "Leanne Graham",
        username: "Bret",
        email: "Sincere@april.biz",
        address: Address(
            street: "Kulas Light",
            suite: "Apt. 556",
            city: "Gwenborough",
            zipcode: "92998-3874",
            geo: Geo(lat: "-37.3159", lng: "81.1496")
        ),
        phone: "1-770-736-8031 x56442",
        website: "hildegard.org",
        company: Company(
            name: "Romaguera-Crona",
            catchPhrase: "Multi-layered client-server neural-net",
            bs: "harness real-time e-markets"
        )
    )
    
    static let mockUsers: [User] = [
        mockUser,
        User(
            id: 2,
            name: "Ervin Howell",
            username: "Antonette",
            email: "Shanna@melissa.tv",
            address: Address(
                street: "Victor Plains",
                suite: "Suite 879",
                city: "Wisokyburgh",
                zipcode: "90566-7771",
                geo: Geo(lat: "-43.9509", lng: "-34.4618")
            ),
            phone: "010-692-6593 x09125",
            website: "anastasia.net",
            company: Company(
                name: "Deckow-Crist",
                catchPhrase: "Proactive didactic contingency",
                bs: "synergize scalable supply-chains"
            )
        )
    ]
}