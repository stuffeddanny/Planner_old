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
}

struct RemindersDictionary: Codable {
    var reminders: [DayModel.ID : [Reminder]]
}
