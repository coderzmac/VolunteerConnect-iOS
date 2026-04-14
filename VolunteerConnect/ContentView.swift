//
//  ContentView.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
//

// ContentView.swift
// VolunteerConnect
//
// The root router view. Decides what to show based on auth state:
//   • Loading spinner  → app is checking if a user is already logged in
//   • LoginView        → no one is logged in
//   • MainTabView      → user is authenticated

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isLoading {
                // Splash / loading state while Firebase checks auth
                splashView
            } else if authViewModel.currentUser != nil {
                // User is signed in — show the main app
                MainTabView()
            } else {
                // No user — show login
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.currentUser?.id)
    }

    // MARK: - Splash View

    private var splashView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green, .green.opacity(0.4))
                .symbolRenderingMode(.hierarchical)

            Text("VolunteerConnect")
                .font(.title)
                .fontWeight(.bold)

            ProgressView()
                .tint(.green)
        }
    }
}
