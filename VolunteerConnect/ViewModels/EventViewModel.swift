//
//  EventViewModel.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// Manages event state for Event-related views.
// Stubbed — Firebase removed. TODO: Restore Firestore listener when SDK is added.

import Foundation
import SwiftUI
import Combine

@MainActor
class EventViewModel: ObservableObject {

    @Published var events:         [Event] = []
    @Published var coordinatorEvents: [Event] = []
    @Published var isLoading:      Bool    = false
    @Published var errorMessage:   String?
    @Published var successMessage: String?

    private var listener: Any?

    // MARK: - Real-Time Listener (Mock)

    func startListening() {
        listener = EventService.shared.listenToUpcomingEvents { [weak self] updatedEvents in
            Task { @MainActor [weak self] in
                self?.events = updatedEvents
            }
        }
    }

    // MARK: - Fetch

    func fetchEvents() async {
        isLoading = true
        do {
            events = try await EventService.shared.fetchUpcomingEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func fetchCoordinatorEvents(coordinatorId: String) async {
        do {
            coordinatorEvents = try await EventService.shared.fetchEventsByCoordinator(coordinatorId: coordinatorId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create Event (Coordinator)

    func createEvent(title: String,
                     description: String,
                     date: Date,
                     location: String,
                     maxVolunteers: Int,
                     coordinator: AppUser) async {

        guard !title.isEmpty, !location.isEmpty else {
            errorMessage = "Please fill in all required fields."
            return
        }

        isLoading = true
        errorMessage = nil

        let event = Event(
            title:           title,
            description:     description,
            date:            date,
            location:        location,
            coordinatorId:   coordinator.id,
            coordinatorName: coordinator.name,
            maxVolunteers:   maxVolunteers
        )

        do {
            _ = try await EventService.shared.createEvent(event)
            successMessage = "Event \"\(title)\" created successfully!"
            await fetchEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Sign Up / Cancel (Volunteer)

    func signUpForEvent(_ event: Event, user: AppUser) async {
        errorMessage = nil
        do {
            try await EventService.shared.signUpVolunteer(
                eventId:       event.id,
                volunteerId:   user.id,
                volunteerName: user.name,
                eventTitle:    event.title,
                eventDate:     event.date
            )
            successMessage = "You're signed up for \"\(event.title)\"!"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func cancelSignUp(for event: Event, userId: String) async {
        errorMessage = nil
        do {
            try await EventService.shared.cancelSignUp(eventId: event.id, volunteerId: userId)
            successMessage = "Sign-up cancelled."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete Event (Coordinator)

    func deleteEvent(_ event: Event) async {
        do {
            try await EventService.shared.deleteEvent(eventId: event.id)
            successMessage = "Event deleted."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers

    func isSignedUp(event: Event, userId: String) -> Bool {
        return event.signedUpVolunteerIds.contains(userId)
    }

    func clearMessages() {
        errorMessage   = nil
        successMessage = nil
    }
}
