//
//  ShiftViewModel.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
//
// Manages shift state for My Shifts and Attendance views.
// Stubbed — Firebase removed. TODO: Restore Firestore listener when SDK is added.

import Foundation
import SwiftUI
import Combine

@MainActor
class ShiftViewModel: ObservableObject {

    @Published var myShifts:    [Shift] = []
    @Published var eventShifts: [Shift] = []
    @Published var isLoading:   Bool    = false
    @Published var errorMessage: String?

    private var listener: Any?

    // MARK: - Computed Helpers

    var upcomingShifts: [Shift] { myShifts.filter { !$0.isPast } }
    var pastShifts:     [Shift] { myShifts.filter {  $0.isPast } }

    var attendedCount: Int { eventShifts.filter { $0.attended }.count }
    var totalCount:    Int { eventShifts.count }

    // MARK: - Real-Time Listener (Mock)

    func startListening(volunteerId: String) {
        listener = ShiftService.shared.listenToVolunteerShifts(volunteerId: volunteerId) { [weak self] shifts in
            Task { @MainActor [weak self] in
                self?.myShifts = shifts
            }
        }
    }

    // MARK: - Fetch

    func fetchMyShifts(volunteerId: String) async {
        isLoading = true
        do {
            myShifts = try await ShiftService.shared.fetchShiftsForVolunteer(volunteerId: volunteerId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func fetchEventShifts(eventId: String) async {
        isLoading = true
        do {
            eventShifts = try await ShiftService.shared.fetchShiftsForEvent(eventId: eventId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Mark Attendance (Coordinator)

    func markAttendance(shift: Shift, attended: Bool) async {
        do {
            try await ShiftService.shared.markAttendance(shiftId: shift.id, attended: attended)
            if let idx = eventShifts.firstIndex(where: { $0.id == shift.id }) {
                eventShifts[idx].attended = attended
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
