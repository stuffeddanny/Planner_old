//
//  DayModel.swift
//  Planner
//
//  Created by Danny on 12/24/22.
//

import SwiftUI

struct DayModel: Identifiable, Equatable, Codable {
    
    let id: Date
    var reminders: [Reminder]
    
}

struct DayModelsHolder: Codable {
    let models: [DayModel]
}
