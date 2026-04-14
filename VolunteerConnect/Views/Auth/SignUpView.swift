//
//  SignUpView.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// New user registration. Users pick a role (Volunteer or Coordinator),
// fill in their details, and create an account backed by Firebase Auth + Firestore.

import SwiftUI

struct SignUpView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    // Form state
    @State private var name            = ""
    @State private var email           = ""
    @State private var phone           = ""
    @State private var password        = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole = .volunteer

    // MARK: - Validation

    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    private var formIsValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !phone.isEmpty &&
        passwordsMatch
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ── Title ──────────────────────────────
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create Account")
                        .font(.largeTitle).fontWeight(.bold)
                    Text("Join the volunteer community")
                        .foregroundColor(.secondary)
                }
                .padding(.top)

                // ── Role Picker ─────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Text("I want to...")
                        .font(.headline)
                    Picker("Role", selection: $selectedRole) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            Text(roleLabel(role)).tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(roleDescription(selectedRole))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                // ── Fields ──────────────────────────────
                Group {
                    FormField(label: "Full Name", icon: "person.fill",
                              placeholder: "Jane Smith", text: $name)

                    FormField(label: "Email", icon: "envelope.fill",
                              placeholder: "jane@example.com", text: $email,
                              keyboardType: .emailAddress)

                    FormField(label: "Phone Number", icon: "phone.fill",
                              placeholder: "(555) 000-0000", text: $phone,
                              keyboardType: .phonePad)

                    FormField(label: "Password", icon: "lock.fill",
                              placeholder: "At least 6 characters",
                              text: $password, isSecure: true)

                    VStack(alignment: .leading, spacing: 4) {
                        FormField(label: "Confirm Password", icon: "lock.shield.fill",
                                  placeholder: "Re-enter password",
                                  text: $confirmPassword, isSecure: true)

                        if !confirmPassword.isEmpty && !passwordsMatch {
                            Label("Passwords do not match", systemImage: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else if passwordsMatch {
                            Label("Passwords match", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }

                // ── Error ───────────────────────────────
                if let error = authViewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(error)
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(10)
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(8)
                }

                // ── Submit ──────────────────────────────
                Button {
                    Task {
                        await authViewModel.signUp(
                            name:     name,
                            email:    email,
                            password: password,
                            role:     selectedRole,
                            phone:    phone
                        )
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(formIsValid ? Color.green : Color.gray.opacity(0.4))
                        if authViewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Create Account")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 50)
                }
                .disabled(!formIsValid || authViewModel.isLoading)

            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationTitle("Sign Up")
        .navigationBarBackButtonHidden(authViewModel.isLoading)
    }

    // MARK: - Helpers

    private func roleLabel(_ role: UserRole) -> String {
        switch role {
        case .volunteer:   return "Volunteer"
        case .coordinator: return "Coordinator"
        }
    }

    private func roleDescription(_ role: UserRole) -> String {
        switch role {
        case .volunteer:
            return "Browse events and sign up for volunteer shifts."
        case .coordinator:
            return "Create and manage events, and track volunteer attendance."
        }
    }
}

// MARK: - Reusable Form Field

struct FormField: View {
    let label:       String
    let icon:        String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure:    Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundColor(.secondary)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                }
            }
            .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
