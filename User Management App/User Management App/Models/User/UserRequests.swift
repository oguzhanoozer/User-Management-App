//
//  UserRequests.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: Strings.CommonErrors.encodingFailed])
        }
        return dictionary
    }
}

struct CreateUserResponse: Codable {
    let id: Int
}

struct CreateUserRequest: Codable {
    let name: String
    let username: String
    let email: String
    let address: CreateAddressRequest?
    let phone: String
    let website: String?
    let company: CreateCompanyRequest?
    
    init(name: String, username: String, email: String, address: CreateAddressRequest? = nil, phone: String, website: String? = nil, company: CreateCompanyRequest? = nil) {
        self.name = name
        self.username = username
        self.email = email
        self.address = address
        self.phone = phone
        self.website = website
        self.company = company
    }
    
    init(from user: User) {
        self.name = user.name
        self.username = user.username
        self.email = user.email
        self.address = CreateAddressRequest(from: user.address)
        self.phone = user.phone
        self.website = user.website
        self.company = CreateCompanyRequest(from: user.company)
    }
}

struct CreateAddressRequest: Codable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
    let geo: CreateGeoRequest
    
    init(street: String, suite: String, city: String, zipcode: String, geo: CreateGeoRequest) {
        self.street = street
        self.suite = suite
        self.city = city
        self.zipcode = zipcode
        self.geo = geo
    }
    
    init(from address: Address) {
        self.street = address.street
        self.suite = address.suite
        self.city = address.city
        self.zipcode = address.zipcode
        self.geo = CreateGeoRequest(from: address.geo)
    }
}

struct CreateGeoRequest: Codable {
    let lat: String
    let lng: String
    
    init(lat: String, lng: String) {
        self.lat = lat
        self.lng = lng
    }
    
    init(from geo: Geo) {
        self.lat = geo.lat
        self.lng = geo.lng
    }
}

struct CreateCompanyRequest: Codable {
    let name: String
    let catchPhrase: String
    let bs: String
    
    init(name: String, catchPhrase: String, bs: String) {
        self.name = name
        self.catchPhrase = catchPhrase
        self.bs = bs
    }
    
    init(from company: Company) {
        self.name = company.name
        self.catchPhrase = company.catchPhrase
        self.bs = company.bs
    }
}

struct UpdateUserRequest: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: CreateAddressRequest
    let phone: String
    let website: String
    let company: CreateCompanyRequest
    
    init(id: Int, name: String, username: String, email: String, address: CreateAddressRequest, phone: String, website: String, company: CreateCompanyRequest) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.address = address
        self.phone = phone
        self.website = website
        self.company = company
    }
    
    init(from user: User) {
        self.id = user.id
        self.name = user.name
        self.username = user.username
        self.email = user.email
        self.address = CreateAddressRequest(from: user.address)
        self.phone = user.phone
        self.website = user.website
        self.company = CreateCompanyRequest(from: user.company)
    }
}

struct DeleteUserResponse: Codable {
    let success: Bool
    let message: String?
    
    static let success = DeleteUserResponse(success: true, message: Strings.API.userDeletedSuccess)
}
