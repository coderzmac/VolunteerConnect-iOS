//
//  AttendanceView.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// Coordinator screen for marking volunteer attendance at an event.
// Shows all signed-up volunteers with a toggle to mark them present/absent.
// Live attendance count shown in the navigation bar.

import SwiftUI

struct AttendanceView: View {

    let event: Event

    @StateObject private var shiftViewModel = ShiftViewModel()

    var body: some View {
        Group {
            if shiftViewModel.isLoading {
                ProgressView("Loading volunteers...")
            } else if shiftViewModel.eventShifts.isEmpty {
                ContentUnavailableView(
                    "No Volunteers",
                    systemImage: "person.fill.xmark",
                    description: Text("No volunteers have signed up for this event yet.")
                )
            } else {
                attendanceList
            }
        }
        .navigationTitle("Attendance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                attendanceCounter
            }
        }
        .task {
            await shiftViewModel.fetchEventShifts(eventId: event.id)
        }
        .alert("Error", isPresented: .constant(shiftViewModel.errorMessage != nil)) {
            Button("OK") { shiftViewModel.errorMessage = nil }
        } message: {
            Text(shiftViewModel.errorMessage ?? "")
        }
    }

    // MARK: - Attendance List

    private var attendanceList: some View {
        List {
            Section {
                ForEach(shiftViewModel.eventShifts) { shift in
                    AttendanceRowView(shift: shift) { attended in
                        Task {
                            await shiftViewModel.markAttendance(shift: shift, attended: attended)
                        }
                    }
                }
            } header: {
                Text("\(event.title)")
            } footer: {
                Text("Tap the circle next to a volunteer's name to mark them as present.")
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Counter Badge

    private var attendanceCounter: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text("\(shiftViewModel.attendedCount)/\(shiftViewModel.totalCount)")
                .font(.headline)
                .foregroundColor(.green)
            Text("present")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Attendance Row

struct AttendanceRowView: View {
    let shift:    Shift
    let onToggle: (Bool) -> Void

    var body: some View {
        HStack {
            // Volunteer info
            VStack(alignment: .leading, spacing: 3) {
                Text(shift.volunteerName)
                    .font(.headline)
                Text("Signed up \(shift.signedUpAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Attendance toggle button
            Button {
                onToggle(!shift.attended)
            } label: {
                Image(systemName: shift.attended
                      ? "checkmark.circle.fill"
                      : "circle")
                    .font(.title2)
                    .foregroundColor(shift.attended ? .green : .gray)
                    .animation(.easeInOut(duration: 0.15), value: shift.attended)
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())   // Make the whole row tappable
        .onTapGesture {
            onToggle(!shift.attended)
        }
        .padding(.vertical, 4)
    }
}
