//
//  MainTabView.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// Root tab bar shown after login.
// Volunteers see: Events | My Shifts | Profile
// Coordinators see: Events | Create Event | Profile

import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var authViewModel: AuthViewModel

    @StateObject private var eventViewModel = EventViewModel()
    @StateObject private var shiftViewModel = ShiftViewModel()

    private var isCoordinator: Bool {
        authViewModel.currentUser?.isCoordinator ?? false
    }

    var body: some View {
        TabView {

            // ── Events (all users) ──────────────────
            EventListView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
                .environmentObject(eventViewModel)

            // ── Role-specific tab ───────────────────
            if isCoordinator {
                CreateEventView()
                    .tabItem {
                        Label("Create", systemImage: "plus.circle.fill")
                    }
                    .environmentObject(eventViewModel)
            } else {
                MyShiftsView()
                    .tabItem {
                        Label("My Shifts", systemImage: "clock.fill")
                    }
                    .environmentObject(shiftViewModel)
            }

            // ── Profile (all users) ─────────────────
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .environmentObject(shiftViewModel)
        }
        .onAppear {
            // Start real-time listeners when the tab bar appears
            eventViewModel.startListening()

            if !isCoordinator, let userId = authViewModel.currentUser?.id {
                shiftViewModel.startListening(volunteerId: userId)
            }
        }
        // Propagate ViewModels to any view that needs them via environment
        .environmentObject(eventViewModel)
        .environmentObject(shiftViewModel)
    }
}
