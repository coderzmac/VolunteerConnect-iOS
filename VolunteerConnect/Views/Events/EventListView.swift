//
//  EventListView.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.

// Shows all upcoming volunteer events.
// Volunteers can browse and tap to sign up.
// Coordinators see the same list but their actions differ in EventDetailView.

import SwiftUI

struct EventListView: View {

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var eventViewModel: EventViewModel

    @State private var searchText = ""

    // MARK: - Filtered Events

    private var filteredEvents: [Event] {
        if searchText.isEmpty { return eventViewModel.events }
        return eventViewModel.events.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.location.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if eventViewModel.isLoading && eventViewModel.events.isEmpty {
                    loadingView
                } else if filteredEvents.isEmpty {
                    emptyView
                } else {
                    eventList
                }
            }
            .navigationTitle("Upcoming Events")
            .searchable(text: $searchText, prompt: "Search by title or location")
            .refreshable {
                await eventViewModel.fetchEvents()
            }
            .alert("Error", isPresented: .constant(eventViewModel.errorMessage != nil)) {
                Button("OK") { eventViewModel.clearMessages() }
            } message: {
                Text(eventViewModel.errorMessage ?? "")
            }
            .alert("", isPresented: .constant(eventViewModel.successMessage != nil)) {
                Button("OK") { eventViewModel.clearMessages() }
            } message: {
                Text(eventViewModel.successMessage ?? "")
            }
        }
        .task {
            if eventViewModel.events.isEmpty {
                await eventViewModel.fetchEvents()
            }
        }
    }

    // MARK: - Sub-Views

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading events...")
                .foregroundColor(.secondary)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            searchText.isEmpty ? "No Upcoming Events" : "No Results",
            systemImage: searchText.isEmpty ? "calendar.badge.exclamationmark" : "magnifyingglass",
            description: Text(
                searchText.isEmpty
                    ? "Check back soon — new events are added regularly."
                    : "Try a different search term."
            )
        )
    }

    private var eventList: some View {
        List(filteredEvents) { event in
            NavigationLink {
                EventDetailView(event: event)
            } label: {
                EventRowView(event: event,
                             isSignedUp: eventViewModel.isSignedUp(
                                event: event,
                                userId: authViewModel.currentUser?.id ?? ""
                             ))
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Event Row

struct EventRowView: View {
    let event:      Event
    let isSignedUp: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack {
                Text(event.title)
                    .font(.headline)
                Spacer()
                if isSignedUp {
                    Label("Signed up", systemImage: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .labelStyle(.iconOnly)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Text(event.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                Text(event.location)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // Spots badge
                Text(event.isFull ? "Full" : "\(event.spotsRemaining) spots left")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(event.isFull ? Color.red.opacity(0.12) : Color.green.opacity(0.12))
                    .foregroundColor(event.isFull ? .red : .green)
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    EventListView()
        .environmentObject(AuthViewModel())
        .environmentObject(EventViewModel())
}

