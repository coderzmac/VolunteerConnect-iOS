//
//  AuthViewModel.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
//
// Manages authentication state for the entire app.
// Passed as an @EnvironmentObject from the root so every view can access it.
// Stubbed — Firebase removed. TODO: Restore Firebase Auth when SDK is added.

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {

    @Published var currentUser: AppUser?
    @Published var isLoading:    Bool    = true
    @Published var errorMessage: String?

    // MARK: - Init

    init() {
        // Auto-login with a mock volunteer so the app shows the main UI
        currentUser = Volunteer(id: "mock-volunteer-1",
                                name: "Jane Smith",
                                email: "jane@example.com",
                                phone: "(555) 123-4567")
        isLoading = false
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async {
        isLoading    = true
        errorMessage = nil
        do {
            currentUser = try await AuthService.shared.signIn(email: email, password: password)
        } catch {
            errorMessage = friendlyError(error)
        }
        isLoading = false
    }

    // MARK: - Sign Up

    func signUp(name: String,
                email: String,
                password: String,
                role: UserRole,
                phone: String) async {
        isLoading    = true
        errorMessage = nil
        do {
            currentUser = try await AuthService.shared.signUp(
                name:     name,
                email:    email,
                password: password,
                role:     role,
                phone:    phone
            )
        } catch {
            errorMessage = friendlyError(error)
        }
        isLoading = false
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try AuthService.shared.signOut()
            currentUser  = nil
            errorMessage = nil
        } catch {
            errorMessage = friendlyError(error)
        }
    }

    // MARK: - Helpers

    private func friendlyError(_ error: Error) -> String {
        let code = (error as NSError).code
        switch code {
        case 17004: return "Wrong email or password."
        case 17007: return "An account with this email already exists."
        case 17008: return "Please enter a valid email address."
        case 17026: return "Password must be at least 6 characters."
        case 17011: return "No account found with this email."
        default:    return error.localizedDescription
        }
    }
}
