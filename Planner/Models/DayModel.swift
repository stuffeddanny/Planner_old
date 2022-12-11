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
    
    init(id: Date, secondary: Bool = false) {
        self.id = id
        self.secondary = secondary
    }
}
