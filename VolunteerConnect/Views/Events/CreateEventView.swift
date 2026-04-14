//
//  CreateEventView.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// Coordinator-only screen for creating new volunteer events.
// Uses a Form layout with sections for clean data entry.

import SwiftUI

struct CreateEventView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventViewModel: EventViewModel

    // Form state
    @State private var title         = ""
    @State private var description   = ""
    @State private var date          = Date().addingTimeInterval(86400)  // Tomorrow by default
    @State private var location      = ""
    @State private var maxVolunteers = 10

    @State private var showSuccess   = false

    // MARK: - Validation

    private var formIsValid: Bool {
        !title.isEmpty && !description.isEmpty && !location.isEmpty && maxVolunteers >= 1
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {

                // ── Event Details ────────────────────────
                Section {
                    TextField("Event title", text: $title)
                    TextField("Location / address", text: $location)
                    DatePicker("Date & Time",
                               selection: $date,
                               in: Date()...,
                               displayedComponents: [.date, .hourAndMinute])
                } header: {
                    Text("Event Details")
                } footer: {
                    Text("Choose a date in the future.")
                }

                // ── Description ──────────────────────────
                Section {
                    TextEditor(text: $description)
                        .frame(minHeight: 110)
                        .overlay(
                            Group {
                                if description.isEmpty {
                                    Text("Describe what volunteers will be doing...")
                                        .foregroundColor(.secondary)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 4)
                                        .allowsHitTesting(false)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity,
                                               alignment: .topLeading)
                                }
                            }
                        )
                } header: {
                    Text("Description")
                }

                // ── Capacity ─────────────────────────────
                Section {
                    Stepper(value: $maxVolunteers, in: 1...500) {
                        HStack {
                            Text("Max Volunteers")
                            Spacer()
                            Text("\(maxVolunteers)")
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                } header: {
                    Text("Volunteer Capacity")
                } footer: {
                    Text("Maximum number of volunteers that can sign up.")
                }

                // ── Error ────────────────────────────────
                if let error = eventViewModel.errorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                // ── Submit ────────────────────────────────
                Section {
                    Button {
                        submitEvent()
                    } label: {
                        ZStack {
                            if eventViewModel.isLoading {
                                HStack {
                                    ProgressView()
                                    Text("Creating event...")
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                Text("Create Event")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .fontWeight(.semibold)
                                    .foregroundColor(formIsValid ? .white : .gray)
                            }
                        }
                    }
                    .listRowBackground(
                        formIsValid
                            ? Color.green
                            : Color(.systemGray5)
                    )
                    .disabled(!formIsValid || eventViewModel.isLoading)
                }
            }
            .navigationTitle("Create Event")
            .alert("Event Created! 🎉", isPresented: $showSuccess) {
                Button("Done") { }
            } message: {
                Text("\"\(title)\" has been posted. Volunteers can now sign up.")
            }
        }
    }

    // MARK: - Submit

    private func submitEvent() {
        guard let coordinator = authViewModel.currentUser else { return }
        let capturedTitle = title   // capture before clearing

        Task {
            await eventViewModel.createEvent(
                title:         capturedTitle,
                description:   description,
                date:          date,
                location:      location,
                maxVolunteers: maxVolunteers,
                coordinator:   coordinator
            )
            if eventViewModel.errorMessage == nil {
                clearForm()
                showSuccess = true
            }
        }
    }

    private func clearForm() {
        title         = ""
        description   = ""
        location      = ""
        maxVolunteers = 10
        date          = Date().addingTimeInterval(86400)
    }
}

#Preview {
    CreateEventView()
        .environmentObject(AuthViewModel())
        .environmentObject(EventViewModel())
}
