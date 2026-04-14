//
//  LoginView.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.

// The entry screen. Users sign in with email + password.
// Tapping "Sign Up" navigates to SignUpView.

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email    = ""
    @State private var password = ""
    @State private var goToSignUp = false

    var canSubmit: Bool {
        !email.isEmpty && password.count >= 6
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                Spacer()

                // ── Header ──────────────────────────────
                VStack(spacing: 12) {
                    Image(systemName: "person.3.sequence.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green, .green.opacity(0.4))
                        .symbolRenderingMode(.hierarchical)

                    Text("VolunteerConnect")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Connecting volunteers to their community")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                // ── Form ────────────────────────────────
                VStack(spacing: 14) {

                    VStack(alignment: .leading, spacing: 4) {
                        Label("Email", systemImage: "envelope")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField("you@example.com", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Label("Password", systemImage: "lock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Error message
                    if let error = authViewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Sign In Button
                    Button {
                        Task { await authViewModel.signIn(email: email, password: password) }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(canSubmit ? Color.green : Color.gray.opacity(0.4))
                            if authViewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(height: 50)
                    }
                    .disabled(!canSubmit || authViewModel.isLoading)
                }
                .padding(.horizontal, 28)

                Spacer()

                // ── Footer ──────────────────────────────
                Button {
                    authViewModel.errorMessage = nil
                    goToSignUp = true
                } label: {
                    HStack(spacing: 4) {
                        Text("New to VolunteerConnect?")
                            .foregroundColor(.secondary)
                        Text("Create an account")
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, 32)
            }
            .navigationDestination(isPresented: $goToSignUp) {
                SignUpView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
