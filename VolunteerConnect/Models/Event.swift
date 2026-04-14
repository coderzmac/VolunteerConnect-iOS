//
//  Event.swift
//  VolunteerConnect
//
//  Created by Emmanuel on 4/14/26.
// Represents a volunteer event created by a Coordinator.
// Volunteers can sign up for Events; each sign-up creates a Shift record.

import Foundation

struct Event: Identifiable, Codable {
    var id: String               // Firestore document ID
    var title: String
    var description: String
    var date: Date
    var location: String
    var coordinatorId: String
    var coordinatorName: String
    var maxVolunteers: Int
    var signedUpVolunteerIds: [String]   // Array of volunteer user IDs
    var isActive: Bool

    // MARK: - Computed Properties

    var spotsRemaining: Int {
        return max(0, maxVolunteers - signedUpVolunteerIds.count)
    }

    var isFull: Bool {
        return signedUpVolunteerIds.count >= maxVolunteers
    }

    var isPast: Bool {
        return date < Date()
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - Init

    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         date: Date,
         location: String,
         coordinatorId: String,
         coordinatorName: String,
         maxVolunteers: Int,
         signedUpVolunteerIds: [String] = [],
         isActive: Bool = true) {
        self.id                   = id
        self.title                = title
        self.description          = description
        self.date                 = date
        self.location             = location
        self.coordinatorId        = coordinatorId
        self.coordinatorName      = coordinatorName
        self.maxVolunteers        = maxVolunteers
        self.signedUpVolunteerIds = signedUpVolunteerIds
        self.isActive             = isActive
    }

    // MARK: - Firestore Serialization (commented out — Firebase not yet added)

    /*
    func toFirestore() -> [String: Any] {
        return [
            "id":                    id,
            "title":                 title,
            "description":           description,
            "date":                  Timestamp(date: date),
            "location":              location,
            "coordinatorId":         coordinatorId,
            "coordinatorName":       coordinatorName,
            "maxVolunteers":         maxVolunteers,
            "signedUpVolunteerIds":  signedUpVolunteerIds,
            "isActive":              isActive
        ]
    }

    static func fromFirestore(id: String, data: [String: Any]) -> Event? {
        guard
            let title           = data["title"]           as? String,
            let description     = data["description"]     as? String,
            let timestamp       = data["date"]            as? Timestamp,
            let location        = data["location"]        as? String,
            let coordinatorId   = data["coordinatorId"]   as? String,
            let coordinatorName = data["coordinatorName"] as? String,
            let maxVolunteers   = data["maxVolunteers"]   as? Int
        else { return nil }

        let signedUpIds = data["signedUpVolunteerIds"] as? [String] ?? []
        let isActive    = data["isActive"] as? Bool ?? true

        return Event(
            id:                   id,
            title:                title,
            description:          description,
            date:                 timestamp.dateValue(),
            location:             location,
            coordinatorId:        coordinatorId,
            coordinatorName:      coordinatorName,
            maxVolunteers:        maxVolunteers,
            signedUpVolunteerIds: signedUpIds,
            isActive:             isActive
        )
    }
    */
}
