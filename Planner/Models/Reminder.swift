//
//  Reminder.swift
//  Planner
//
//  Created by Danny on 12/1/22.
//

import Foundation


struct Reminder: Identifiable, Codable, Equatable, Hashable {
    var id = UUID()
    var completed: Bool = false
    var headline: String = ""
    var note: String = ""
    var justCreated = true
    var tagId: UUID? = nil
    var date: Date? = nil
}

struct RemindersDictionary: Codable {
    var reminders: [DayModel.ID : [Reminder]]
}

extension Reminder {
    static func SnapshotReminders() -> [Reminder] {
        [
            Reminder(headline: "Buy chicken"),
            Reminder(headline: "Do sports"),
            Reminder(headline: "Cook dinner"),
            Reminder(headline: "Watch movie"),
            Reminder(headline: "House cleaning")
        ]
    }
}
