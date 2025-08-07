//
//  Strings.swift
//  User Management App
//
//  Created by oguzhan on 4.08.2025.
//

import Foundation

struct Strings {
    
    
    struct App {
        static let title = "User Management"
        static let subtitle = "App"
    }
    
    
    struct Navigation {
        static let users = "Users"
        static let newUser = "New User"
    }
    
    
    struct Actions {
        static let cancel = "Cancel"
        static let ok = "OK"
        static let save = "Save"
        static let tryAgain = "Try Again"
        static let edit = "Edit"
        static let delete = "Delete"
        static let add = "Add"
    }
    
    
    struct Loading {
        static let users = "Loading users..."
        static let detail = "Loading details..."
        static let updating = "Updating..."
        static let deleting = "Deleting..."
        static let creating = "Creating user..."
        static let page = "Loading page..."
        static let userDetail = "Loading user details..."
        static let backendSync = "Syncing with backend API..."
        static let allUsersLoaded = "All users loaded"
    }
    
    
    struct Errors {
        static let general = "Error"
        static let serverResponse = "❌ Server response error!\n\nPlease try again."
        static let invalidURL = "❌ Invalid URL error!\n\nPlease try again."
        static let timeout = "❌ Timeout error!\n\nCheck your connection."
        static let noInternet = "❌ No internet connection!\n\nCheck your connection."
        static let deleteNotStarted = "❌ Backend delete operation could not be started"
        
        static func network(_ message: String) -> String {
            return "❌ Network error!\n\nCheck your connection.\n\nDetail: \(message)"
        }
        
        static func dataDecoding(_ message: String) -> String {
            return "❌ Data error!\n\nDetail: \(message)"
        }
        
        static func serverError(_ code: Int, _ message: String) -> String {
            return "❌ Server error (\(code))!\n\nDetail: \(message)"
        }
        
        static func unknown(_ message: String) -> String {
            return "❌ Unknown error!\n\nDetail: \(message)"
        }
        
        static func apiGeneral(_ message: String) -> String {
            return "❌ Backend API error!\n\n🌐 POST request failed\n\nDetail: \(message)"
        }
        
        static func updateFailed(_ message: String) -> String {
            return "❌ Backend API Update Error!\n\n🌐 PUT request failed\n\nDetail: \(message)"
        }
        
        static func deleteFailed(_ message: String) -> String {
            return "❌ Backend API Delete Error!\n\n🌐 DELETE request failed\n\nDetail: \(message)"
        }
    }
    
    
    struct Success {
        static func userCreated(name: String, email: String, phone: String, id: Int) -> String {
            return "✅ User added!\n\n👤 \(name)\n📧 \(email)\n📞 \(phone)\n🆔 ID: \(id)"
        }
        
        static func userUpdated(name: String, email: String) -> String {
            return "✅ User updated!\n\n👤 New Name: \(name)\n📧 New Email: \(email)\n🌐 PUT request successful"
        }
        
        static func userDeleted(name: String) -> String {
            return "✅ User deleted!\n\n🗑️ \(name) is no longer in the system\n🌐 DELETE request successful"
        }
    }
    
    
    struct FormFields {
        static let fullName = "Full Name"
        static let username = "Username"
        static let email = "Email"
        static let phone = "Phone (10 digits)"
        static let name = "Name"
    }
    
    
    struct Placeholders {
        static let fullName = "e.g. John Doe"
        static let username = "e.g. johndoe"
        static let email = "e.g. john@example.com"
        static let phone = "5551234567"
        static let name = "Name"
        static let emailField = "Email"
    }
    
    
    struct Validation {
        static let fillAllFields = "❌ Please fill all fields correctly"
        
        struct Name {
            static let required = "Full name is required"
            static let tooShort = "Full name must be at least 2 characters"
            static let tooLong = "Full name can be at most 50 characters"
        }
        
        struct Username {
            static let required = "Username is required"
            static let tooShort = "Username must be at least 3 characters"
            static let tooLong = "Username can be at most 20 characters"
            static let invalidCharacters = "Only letters, numbers, _ and . are allowed"
        }
        
        struct Email {
            static let required = "Email address is required"
            static let invalid = "Please enter a valid email address"
        }
        
        struct Phone {
            static let required = "Phone number is required"
            static let invalidLength = "Phone number must be 10 digits"
        }
    }
    
    
    struct DetailSections {
        static let contactInfo = "Contact Information"
        static let addressInfo = "Address Information"
        static let companyInfo = "Company Information"
        static let personalInfo = "Personal Information"
    }
    
    
    struct DetailRows {
        static let email = "Email"
        static let phone = "Phone"
        static let website = "Website"
        static let fullAddress = "Full Address"
        static let city = "City"
        static let zipcode = "Zip Code"
        static let company = "Company"
        static let position = "Position"
        static let call = "Call"
        static let message = "Message"
        static let sendEmail = "Send Email"
    }
    
    
    struct FormSections {
        static let newUser = "Add New User"
        static let userInfo = "User Information"
        static let fillAllFields = "Fill all fields"
        static let updateUserInfo = "Update user information"
    }
    
    
    struct AlertTitles {
        static let result = "Operation Result"
        static let deleteConfirmation = "Are you sure you want to delete this user?"
        static let editUser = "Edit User"
        static let deleteUser = "Delete User"
    }
    
    
    struct Buttons {
        static let addUser = "Add User"
        static let addingUser = "Adding User..."
        static let updateUser = "Update User"
        static let deleteUser = "Delete User"
        static let retryLoad = "Retry Load"
    }
    
    
    struct Detail {
        static let zipCode = "Zip Code"
        static let slogan = "Slogan"
        static let businessField = "Business Field"
        static let memberSince = "Member since 2019"
    }
    
    
    struct CommonErrors {
        static let unknown = "Unknown error"
        static let userNotFound = "User not found"
        static let encodingFailed = "Failed to convert to dictionary"
        static let networkTimeout = "Network timeout"
        static let noInternetConnection = "No internet connection"
        static let invalidResponse = "Invalid server response"
        static let decodingFailed = "Failed to decode server response"
    }
    
    
    struct API {
        static let userDeletedSuccess = "User deleted successfully"
    }
}
