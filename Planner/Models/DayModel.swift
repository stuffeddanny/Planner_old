//
//  DayModel.swift
//  Planner
//
//  Created by Danny on 11/26/22.
//

import Foundation

struct DayModel: Identifiable, Equatable {
    let id: Date
    let secondary: Bool
    var reminders: [Reminder]
    
    init(id: Date, reminders: [Reminder] = [], secondary: Bool = false) {
        self.id = id
        self.reminders = reminders
        self.secondary = secondary
    }
}
