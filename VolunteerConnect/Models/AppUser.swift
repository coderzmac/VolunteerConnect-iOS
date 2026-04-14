//
//  AppUser.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// OOP Design: AppUser is the base class.
// Volunteer and Coordinator are subclasses that extend it.
// UserRole enum acts as the discriminator for role-based behavior.

import Foundation
import Combine

// MARK: - UserRole Enum

enum UserRole: String, Codable, CaseIterable {
    case volunteer   = "volunteer"
    case coordinator = "coordinator"

    var displayName: String {
        switch self {
        case .volunteer:   return "Volunteer"
        case .coordinator: return "Coordinator"
        }
    }
}

// MARK: - Base User Class (OOP Base Class)

class AppUser: Identifiable, ObservableObject {
    var id: String
    var name: String
    var email: String
    var role: UserRole
    var phone: String

    var isCoordinator: Bool { role == .coordinator }

    init(id: String, name: String, email: String, role: UserRole, phone: String = "") {
        self.id    = id
        self.name  = name
        self.email = email
        self.role  = role
        self.phone = phone
    }

    // Firestore serialization (commented out — Firebase not yet added)

    /*
    func toFirestore() -> [String: Any] {
        return [
            "id":    id,
            "name":  name,
            "email": email,
            "role":  role.rawValue,
            "phone": phone
        ]
    }

    static func fromFirestore(id: String, data: [String: Any]) -> AppUser? {
        guard
            let name  = data["name"]  as? String,
            let email = data["email"] as? String,
            let roleRaw = data["role"] as? String,
            let role  = UserRole(rawValue: roleRaw)
        else { return nil }

        let phone = data["phone"] as? String ?? ""

        switch role {
        case .volunteer:
            return Volunteer(id: id, name: name, email: email, phone: phone)
        case .coordinator:
            return Coordinator(id: id, name: name, email: email, phone: phone)
        }
    }
    */
}

// MARK: - Volunteer Subclass (OOP Inheritance)

class Volunteer: AppUser {
    var signedUpEventIds: [String]

    init(id: String, name: String, email: String, phone: String = "",
         signedUpEventIds: [String] = []) {
        self.signedUpEventIds = signedUpEventIds
        super.init(id: id, name: name, email: email, role: .volunteer, phone: phone)
    }

    // Sign up for an event
    func signUp(for eventId: String) {
        if !signedUpEventIds.contains(eventId) {
            signedUpEventIds.append(eventId)
        }
    }

    // Cancel sign-up
    func cancelSignUp(for eventId: String) {
        signedUpEventIds.removeAll { $0 == eventId }
    }

    func isSignedUpFor(eventId: String) -> Bool {
        return signedUpEventIds.contains(eventId)
    }
}

// MARK: - Coordinator Subclass (OOP Inheritance)

class Coordinator: AppUser {
    var createdEventIds: [String]

    init(id: String, name: String, email: String, phone: String = "",
         createdEventIds: [String] = []) {
        self.createdEventIds = createdEventIds
        super.init(id: id, name: name, email: email, role: .coordinator, phone: phone)
    }

    // Track events created by this coordinator
    func addEvent(eventId: String) {
        if !createdEventIds.contains(eventId) {
            createdEventIds.append(eventId)
        }
    }
}
