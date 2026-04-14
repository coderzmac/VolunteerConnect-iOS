//
//  EventDetailView.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.

// Full details for a single event.
// Volunteers: see details + sign up / cancel.
// Coordinators: see details + track attendance + delete event.

import SwiftUI

struct EventDetailView: View {

    let event: Event

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventViewModel: EventViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirm = false
    @State private var isWorking         = false

    // MARK: - Computed

    private var currentUserId: String {
        authViewModel.currentUser?.id ?? ""
    }

    private var isCoordinator: Bool {
        authViewModel.currentUser?.isCoordinator ?? false
    }

    private var isMyEvent: Bool {
        event.coordinatorId == currentUserId
    }

    private var isSignedUp: Bool {
        eventViewModel.isSignedUp(event: event, userId: currentUserId)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ── Header ──────────────────────────────
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Label("Organized by \(event.coordinatorName)",
                          systemImage: "person.fill.badge.plus")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // ── Info Cards ──────────────────────────
                VStack(spacing: 12) {
                    InfoCard(icon: "calendar",          iconColor: .green,
                             title: "Date & Time",      value: event.formattedDate)
                    InfoCard(icon: "mappin.and.ellipse", iconColor: .red,
                             title: "Location",         value: event.location)
                    InfoCard(icon: "person.2.fill",     iconColor: .blue,
                             title: "Volunteers",
                             value: "\(event.signedUpVolunteerIds.count) / \(event.maxVolunteers) signed up  •  \(event.spotsRemaining) spots left")
                }

                // ── Description ─────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Text("About This Event")
                        .font(.headline)
                    Text(event.description)
                        .foregroundColor(.secondary)
                }

                Divider()

                // ── Action Buttons ───────────────────────
                actionSection

            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Event", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await eventViewModel.deleteEvent(event)
                    dismiss()
                }
            }
        } message: {
            Text("This will permanently remove \"\(event.title)\" and cannot be undone.")
        }
        .alert("Error", isPresented: .constant(eventViewModel.errorMessage != nil)) {
            Button("OK") { eventViewModel.clearMessages() }
        } message: {
            Text(eventViewModel.errorMessage ?? "")
        }
    }

    // MARK: - Action Section

    @ViewBuilder
    private var actionSection: some View {
        if isCoordinator {
            coordinatorActions
        } else {
            volunteerActions
        }
    }

    private var volunteerActions: some View {
        VStack(spacing: 12) {
            if isSignedUp {
                // Cancel sign-up
                Button {
                    Task {
                        isWorking = true
                        await eventViewModel.cancelSignUp(for: event, userId: currentUserId)
                        isWorking = false
                        dismiss()
                    }
                } label: {
                    ActionButtonLabel(title: "Cancel My Sign-Up",
                                      icon:  "xmark.circle.fill",
                                      color: .red,
                                      isLoading: isWorking)
                }
            } else {
                // Sign up
                Button {
                    Task {
                        guard let user = authViewModel.currentUser else { return }
                        isWorking = true
                        await eventViewModel.signUpForEvent(event, user: user)
                        isWorking = false
                        if eventViewModel.errorMessage == nil { dismiss() }
                    }
                } label: {
                    ActionButtonLabel(title: "Sign Up to Volunteer",
                                      icon:  "checkmark.circle.fill",
                                      color: event.isFull ? .gray : .green,
                                      isLoading: isWorking)
                }
                .disabled(event.isFull || isWorking)

                if event.isFull {
                    Text("This event is currently full.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }

    private var coordinatorActions: some View {
        VStack(spacing: 12) {
            if isMyEvent {
                NavigationLink {
                    AttendanceView(event: event)
                } label: {
                    ActionButtonLabel(title: "Track Attendance",
                                      icon:  "checkmark.seal.fill",
                                      color: .blue,
                                      isLoading: false)
                }

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    ActionButtonLabel(title: "Delete Event",
                                      icon:  "trash.fill",
                                      color: .red,
                                      isLoading: false)
                }
            } else {
                // Viewing another coordinator's event
                Text("You are viewing an event managed by \(event.coordinatorName).")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Supporting Views

struct InfoCard: View {
    let icon:       String
    let iconColor:  Color
    let title:      String
    let value:      String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ActionButtonLabel: View {
    let title:     String
    let icon:      String
    let color:     Color
    let isLoading: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.12))
            if isLoading {
                ProgressView().tint(color)
            } else {
                Label(title, systemImage: icon)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
        }
        .frame(height: 50)
    }
}
