//
//  EventService.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// Stubbed version — Firebase removed so the app can build and preview UI.
// TODO: Restore Firestore operations when the SDK is added.

import Foundation

class EventService {

    static let shared = EventService()
    private init() {
        // Pre-populate with sample events
        _events = EventService.sampleEvents()
    }

    private var _events: [Event] = []

    // MARK: - Sample Data

    private static func sampleEvents() -> [Event] {
        let calendar = Calendar.current
        return [
            Event(id: "evt-1",
                  title: "Park Cleanup Drive",
                  description: "Help clean up Riverside Park! We'll be picking up litter, planting flowers, and painting benches. Gloves and bags provided.",
                  date: calendar.date(byAdding: .day, value: 3, to: Date())!,
                  location: "Riverside Park, Main St",
                  coordinatorId: "coord-1",
                  coordinatorName: "Alex Johnson",
                  maxVolunteers: 25,
                  signedUpVolunteerIds: ["mock-volunteer-1", "vol-2", "vol-3"]),

            Event(id: "evt-2",
                  title: "Food Bank Sorting",
                  description: "Sort and package food donations at the community food bank. Great for groups and families!",
                  date: calendar.date(byAdding: .day, value: 5, to: Date())!,
                  location: "Community Food Bank, 200 Oak Ave",
                  coordinatorId: "coord-1",
                  coordinatorName: "Alex Johnson",
                  maxVolunteers: 15,
                  signedUpVolunteerIds: ["vol-4", "vol-5"]),

            Event(id: "evt-3",
                  title: "Senior Center Visit",
                  description: "Spend time with seniors at Sunny Acres. Activities include board games, reading, and conversation.",
                  date: calendar.date(byAdding: .day, value: 7, to: Date())!,
                  location: "Sunny Acres Senior Center",
                  coordinatorId: "coord-2",
                  coordinatorName: "Maria Garcia",
                  maxVolunteers: 10,
                  signedUpVolunteerIds: ["mock-volunteer-1"]),

            Event(id: "evt-4",
                  title: "Youth Tutoring Program",
                  description: "Tutor middle school students in math and reading at the public library. Training provided for new volunteers.",
                  date: calendar.date(byAdding: .day, value: 10, to: Date())!,
                  location: "Central Public Library",
                  coordinatorId: "coord-2",
                  coordinatorName: "Maria Garcia",
                  maxVolunteers: 8,
                  signedUpVolunteerIds: ["vol-6", "vol-7", "vol-8", "vol-9", "vol-10", "vol-11", "vol-12", "vol-13"]),

            Event(id: "evt-5",
                  title: "Animal Shelter Help Day",
                  description: "Walk dogs, socialize cats, and help with general shelter maintenance. Must be 16+.",
                  date: calendar.date(byAdding: .day, value: 14, to: Date())!,
                  location: "Happy Paws Animal Shelter",
                  coordinatorId: "coord-1",
                  coordinatorName: "Alex Johnson",
                  maxVolunteers: 12,
                  signedUpVolunteerIds: [])
        ]
    }

    // MARK: - Create

    func createEvent(_ event: Event) async throws -> String {
        try await Task.sleep(nanoseconds: 300_000_000)
        _events.append(event)
        return event.id
    }

    // MARK: - Read

    func fetchUpcomingEvents() async throws -> [Event] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return _events.filter { $0.isActive }.sorted { $0.date < $1.date }
    }

    func fetchEventsByCoordinator(coordinatorId: String) async throws -> [Event] {
        return _events.filter { $0.coordinatorId == coordinatorId }
    }

    // MARK: - Update

    func updateEvent(_ event: Event) async throws {
        if let idx = _events.firstIndex(where: { $0.id == event.id }) {
            _events[idx] = event
        }
    }

    func deleteEvent(eventId: String) async throws {
        if let idx = _events.firstIndex(where: { $0.id == eventId }) {
            _events[idx].isActive = false
        }
    }

    // MARK: - Sign Up / Cancel (Mock)

    func signUpVolunteer(eventId: String,
                         volunteerId: String,
                         volunteerName: String,
                         eventTitle: String,
                         eventDate: Date) async throws {
        if let idx = _events.firstIndex(where: { $0.id == eventId }) {
            guard !_events[idx].signedUpVolunteerIds.contains(volunteerId) else {
                throw NSError(domain: "EventService", code: 409,
                              userInfo: [NSLocalizedDescriptionKey: "You are already signed up for this event."])
            }
            guard !_events[idx].isFull else {
                throw NSError(domain: "EventService", code: 422,
                              userInfo: [NSLocalizedDescriptionKey: "This event is already full."])
            }
            _events[idx].signedUpVolunteerIds.append(volunteerId)
        }

        let shift = Shift(eventId: eventId, volunteerId: volunteerId,
                          volunteerName: volunteerName, eventTitle: eventTitle, eventDate: eventDate)
        try await ShiftService.shared.createShift(shift)
    }

    func cancelSignUp(eventId: String, volunteerId: String) async throws {
        if let idx = _events.firstIndex(where: { $0.id == eventId }) {
            _events[idx].signedUpVolunteerIds.removeAll { $0 == volunteerId }
        }
        try await ShiftService.shared.deleteShift(eventId: eventId, volunteerId: volunteerId)
    }

    // MARK: - Real-Time Listener (No-op stub)

    func listenToUpcomingEvents(onChange: @escaping ([Event]) -> Void) -> Any {
        // Immediately fire with current data
        onChange(_events.filter { $0.isActive }.sorted { $0.date < $1.date })
        return NSObject() // placeholder handle
    }
}
