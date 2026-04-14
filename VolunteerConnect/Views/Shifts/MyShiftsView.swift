//
//  MyShiftsView.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// Volunteer-only screen. Shows all shifts the volunteer has signed up for,
// split into Upcoming and Past sections. Attendance status shown for past shifts.

import SwiftUI

struct MyShiftsView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var shiftViewModel: ShiftViewModel

    var body: some View {
        NavigationStack {
            Group {
                if shiftViewModel.isLoading && shiftViewModel.myShifts.isEmpty {
                    ProgressView("Loading your shifts...")
                } else if shiftViewModel.myShifts.isEmpty {
                    emptyState
                } else {
                    shiftList
                }
            }
            .navigationTitle("My Shifts")
            .refreshable {
                if let userId = authViewModel.currentUser?.id {
                    await shiftViewModel.fetchMyShifts(volunteerId: userId)
                }
            }
        }
        .task {
            if let userId = authViewModel.currentUser?.id,
               shiftViewModel.myShifts.isEmpty {
                await shiftViewModel.fetchMyShifts(volunteerId: userId)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Shifts Yet", systemImage: "clock.badge.exclamationmark")
        } description: {
            Text("Browse upcoming events and sign up to start volunteering.")
        }
    }

    // MARK: - Shift List

    private var shiftList: some View {
        List {
            if !shiftViewModel.upcomingShifts.isEmpty {
                Section("Upcoming (\(shiftViewModel.upcomingShifts.count))") {
                    ForEach(shiftViewModel.upcomingShifts) { shift in
                        ShiftRowView(shift: shift)
                    }
                }
            }

            if !shiftViewModel.pastShifts.isEmpty {
                Section("Past (\(shiftViewModel.pastShifts.count))") {
                    ForEach(shiftViewModel.pastShifts) { shift in
                        ShiftRowView(shift: shift)
                    }
                }
            }

            // Summary footer
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total events joined")
                            .font(.caption).foregroundColor(.secondary)
                        Text("\(shiftViewModel.myShifts.count)")
                            .font(.title3).fontWeight(.bold)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Confirmed attended")
                            .font(.caption).foregroundColor(.secondary)
                        Text("\(shiftViewModel.pastShifts.filter { $0.attended }.count)")
                            .font(.title3).fontWeight(.bold).foregroundColor(.green)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Shift Row

struct ShiftRowView: View {
    let shift: Shift

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(shift.eventTitle)
                    .font(.headline)
                Spacer()
                statusBadge
            }

            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(shift.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if shift.isPast {
            Label(shift.attended ? "Attended" : "Not recorded",
                  systemImage: shift.attended ? "checkmark.circle.fill" : "circle.dashed")
                .font(.caption2)
                .foregroundColor(shift.attended ? .green : .orange)
                .labelStyle(.iconOnly)
        } else {
            Text("Upcoming")
                .font(.caption2)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color.blue.opacity(0.12))
                .foregroundColor(.blue)
                .cornerRadius(6)
        }
    }
}

#Preview {
    MyShiftsView()
        .environmentObject(AuthViewModel())
        .environmentObject(ShiftViewModel())
}
