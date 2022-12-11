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
            Reminder(headline: "Buy chicken", note: "120g chicken breast", date: .now.advanced(by: 60 * 60 * 30)),
            Reminder(headline: "Do sports", note: "Running + yoga", date: .now.advanced(by: 60 * 60 * 100)),
            Reminder(headline: "Cook dinner", note: "Chicken with mushrooms", date: .now.advanced(by: 60 * 60 * 150)),
            Reminder(headline: "Watch movie", note: "Home alone 2", date: .now.advanced(by: 60 * 60 * 200)),
            Reminder(headline: "Prepare for test", note: "Math + Java", date: .now.advanced(by: 60 * 60 * 250)),
            Reminder(headline: "House cleaning", note: "Bedroom + bathroom", date: .now.advanced(by: 60 * 60 * 300))
        ]
    }
}
