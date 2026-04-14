//
//  ShiftService.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// Stubbed version — Firebase removed so the app can build and preview UI.
// TODO: Restore Firestore operations when the SDK is added.

import Foundation

class ShiftService {

    static let shared = ShiftService()
    private init() {
        // Pre-populate with sample shifts for the mock volunteer
        _shifts = ShiftService.sampleShifts()
    }

    private var _shifts: [Shift] = []

    // MARK: - Sample Data

    private static func sampleShifts() -> [Shift] {
        let calendar = Calendar.current
        return [
            Shift(eventId: "evt-1",
                  volunteerId: "mock-volunteer-1",
                  volunteerName: "Jane Smith",
                  eventTitle: "Park Cleanup Drive",
                  eventDate: calendar.date(byAdding: .day, value: 3, to: Date())!),
            Shift(eventId: "evt-3",
                  volunteerId: "mock-volunteer-1",
                  volunteerName: "Jane Smith",
                  eventTitle: "Senior Center Visit",
                  eventDate: calendar.date(byAdding: .day, value: 7, to: Date())!),
            // A past shift
            Shift(eventId: "evt-past-1",
                  volunteerId: "mock-volunteer-1",
                  volunteerName: "Jane Smith",
                  eventTitle: "Beach Cleanup",
                  eventDate: calendar.date(byAdding: .day, value: -10, to: Date())!,
                  attended: true),
            Shift(eventId: "evt-past-2",
                  volunteerId: "mock-volunteer-1",
                  volunteerName: "Jane Smith",
                  eventTitle: "Soup Kitchen",
                  eventDate: calendar.date(byAdding: .day, value: -3, to: Date())!,
                  attended: false),
        ]
    }

    // MARK: - Create

    func createShift(_ shift: Shift) async throws {
        _shifts.append(shift)
    }

    // MARK: - Read

    func fetchShiftsForVolunteer(volunteerId: String) async throws -> [Shift] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return _shifts
            .filter { $0.volunteerId == volunteerId }
            .sorted { $0.eventDate < $1.eventDate }
    }

    func fetchShiftsForEvent(eventId: String) async throws -> [Shift] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return _shifts
            .filter { $0.eventId == eventId }
            .sorted { $0.volunteerName < $1.volunteerName }
    }

    // MARK: - Update

    func markAttendance(shiftId: String, attended: Bool) async throws {
        if let idx = _shifts.firstIndex(where: { $0.id == shiftId }) {
            _shifts[idx].attended = attended
        }
    }

    // MARK: - Delete

    func deleteShift(eventId: String, volunteerId: String) async throws {
        _shifts.removeAll { $0.eventId == eventId && $0.volunteerId == volunteerId }
    }

    // MARK: - Real-Time Listener (No-op stub)

    func listenToVolunteerShifts(volunteerId: String, onChange: @escaping ([Shift]) -> Void) -> Any {
        let shifts = _shifts
            .filter { $0.volunteerId == volunteerId }
            .sorted { $0.eventDate < $1.eventDate }
        onChange(shifts)
        return NSObject()
    }
}
