//
//  Reminder.swift
//  Planner
//
//  Created by Danny on 12/1/22.
//

import Foundation


struct Reminder: Identifiable, Codable, Equatable {
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
            Reminder(completed: .random(), headline: "Buy chicken"),
            Reminder(completed: .random(), headline: "Do sports"),
            Reminder(completed: .random(), headline: "Cook dinner"),
            Reminder(completed: .random(), headline: "Watch movie"),
            Reminder(completed: .random(), headline: "House cleaning")
        ]
    }
}
