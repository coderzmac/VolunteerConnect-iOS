//
//  AuthService.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// Stubbed version — Firebase removed so the app can build and preview UI.
// TODO: Restore Firebase Auth + Firestore when the SDK is added.

import Foundation

class AuthService {

    static let shared = AuthService()
    private init() {}

    // MARK: - Mock Auth State

    private var _currentUser: AppUser?

    var currentFirebaseUser: AnyObject? {
        return nil
    }

    // MARK: - Sign Up (Mock)

    func signUp(name: String,
                email: String,
                password: String,
                role: UserRole,
                phone: String) async throws -> AppUser {

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        let uid = UUID().uuidString
        let user: AppUser
        switch role {
        case .volunteer:
            user = Volunteer(id: uid, name: name, email: email, phone: phone)
        case .coordinator:
            user = Coordinator(id: uid, name: name, email: email, phone: phone)
        }
        _currentUser = user
        return user
    }

    // MARK: - Sign In (Mock)

    func signIn(email: String, password: String) async throws -> AppUser {
        try await Task.sleep(nanoseconds: 500_000_000)

        // Return a mock volunteer user
        let user = Volunteer(id: "mock-volunteer-1",
                             name: "Jane Smith",
                             email: email,
                             phone: "(555) 123-4567")
        _currentUser = user
        return user
    }

    // MARK: - Sign Out

    func signOut() throws {
        _currentUser = nil
    }
}
