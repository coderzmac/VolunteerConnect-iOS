//
//  VolunteerConnectApp.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
//

// VolunteerConnectApp.swift
// VolunteerConnect
//
// App entry point. Configures Firebase and injects AuthViewModel
// into the environment so every view can access auth state.

import SwiftUI

@main
struct VolunteerConnectApp: App {

    // Create AuthViewModel once at the app level
    @StateObject private var authViewModel = AuthViewModel()

    // TODO: Restore FirebaseApp.configure() when Firebase SDK is added

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
