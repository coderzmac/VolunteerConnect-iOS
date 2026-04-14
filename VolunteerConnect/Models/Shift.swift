//
//  Shift.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// A Shift is created when a Volunteer signs up for an Event.
// It links a Volunteer to an Event and tracks attendance.
// OOP: Shift is the association/join class between Volunteer and Event.

import Foundation

struct Shift: Identifiable, Codable {
    var id: String               // Firestore document ID
    var eventId: String
    var volunteerId: String
    var volunteerName: String
    var eventTitle: String
    var eventDate: Date
    var attended: Bool
    var signedUpAt: Date

    // MARK: - Computed Properties

    var isPast: Bool {
        return eventDate < Date()
    }

    var statusLabel: String {
        if isPast {
            return attended ? "Attended ✓" : "Did not attend"
        }
        return "Upcoming"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: eventDate)
    }

    // MARK: - Init

    init(id: String = UUID().uuidString,
         eventId: String,
         volunteerId: String,
         volunteerName: String,
         eventTitle: String,
         eventDate: Date,
         attended: Bool = false,
         signedUpAt: Date = Date()) {
        self.id            = id
        self.eventId       = eventId
        self.volunteerId   = volunteerId
        self.volunteerName = volunteerName
        self.eventTitle    = eventTitle
        self.eventDate     = eventDate
        self.attended      = attended
        self.signedUpAt    = signedUpAt
    }

    // MARK: - Firestore Serialization (commented out — Firebase not yet added)

    /*
    func toFirestore() -> [String: Any] {
        return [
            "id":            id,
            "eventId":       eventId,
            "volunteerId":   volunteerId,
            "volunteerName": volunteerName,
            "eventTitle":    eventTitle,
            "eventDate":     Timestamp(date: eventDate),
            "attended":      attended,
            "signedUpAt":    Timestamp(date: signedUpAt)
        ]
    }

    static func fromFirestore(id: String, data: [String: Any]) -> Shift? {
        guard
            let eventId       = data["eventId"]       as? String,
            let volunteerId   = data["volunteerId"]   as? String,
            let volunteerName = data["volunteerName"] as? String,
            let eventTitle    = data["eventTitle"]    as? String,
            let eventTimestamp = data["eventDate"]    as? Timestamp
        else { return nil }

        let attended = data["attended"] as? Bool ?? false
        let signedUpTimestamp = data["signedUpAt"] as? Timestamp ?? Timestamp(date: Date())

        return Shift(
            id:            id,
            eventId:       eventId,
            volunteerId:   volunteerId,
            volunteerName: volunteerName,
            eventTitle:    eventTitle,
            eventDate:     eventTimestamp.dateValue(),
            attended:      attended,
            signedUpAt:    signedUpTimestamp.dateValue()
        )
    }
    */
}
