//
//  ProfileView.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// Displays the signed-in user's profile information.
// Volunteers see their volunteering stats.
// Both roles can sign out from here.

import SwiftUI

struct ProfileView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var shiftViewModel: ShiftViewModel

    @State private var showSignOutConfirm = false

    private var user: AppUser? { authViewModel.currentUser }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {

                // ── Avatar + Name ────────────────────────
                Section {
                    HStack(spacing: 16) {
                        avatarCircle
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user?.name ?? "—")
                                .font(.title3)
                                .fontWeight(.semibold)
                            roleBadge
                        }
                    }
                    .padding(.vertical, 8)
                }

                // ── Contact Info ─────────────────────────
                Section("Contact Information") {
                    LabeledContent {
                        Text(user?.email ?? "—")
                            .foregroundColor(.secondary)
                    } label: {
                        Label("Email", systemImage: "envelope.fill")
                    }

                    LabeledContent {
                        Text(user?.phone.isEmpty == false ? user!.phone : "Not provided")
                            .foregroundColor(.secondary)
                    } label: {
                        Label("Phone", systemImage: "phone.fill")
                    }
                }

                // ── Volunteer Stats ──────────────────────
                if user?.role == .volunteer {
                    Section("Volunteer Stats") {
                        statRow(icon: "calendar.badge.checkmark",
                                label: "Total Events Joined",
                                value: "\(shiftViewModel.myShifts.count)",
                                color: .blue)

                        statRow(icon: "checkmark.seal.fill",
                                label: "Events Attended",
                                value: "\(shiftViewModel.pastShifts.filter { $0.attended }.count)",
                                color: .green)

                        statRow(icon: "clock.fill",
                                label: "Upcoming Shifts",
                                value: "\(shiftViewModel.upcomingShifts.count)",
                                color: .orange)
                    }
                }

                // ── Sign Out ─────────────────────────────
                Section {
                    Button(role: .destructive) {
                        showSignOutConfirm = true
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .alert("Sign Out?", isPresented: $showSignOutConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("You will be returned to the login screen.")
            }
        }
    }

    // MARK: - Helpers

    private var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.15))
                .frame(width: 64, height: 64)
            Text(user?.name.prefix(1).uppercased() ?? "?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
    }

    private var roleBadge: some View {
        Text(user?.role.displayName ?? "")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(user?.isCoordinator == true
                        ? Color.blue.opacity(0.12)
                        : Color.green.opacity(0.12))
            .foregroundColor(user?.isCoordinator == true ? .blue : .green)
            .cornerRadius(8)
    }

    private func statRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(ShiftViewModel())
}
