//
//  Calendar.swift
//  Planner
//
//  Created by Danny on 12/13/22.
//

import Foundation

extension Calendar {
    static var gregorianWithSunAsFirstWeekday: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        return calendar
    }
}
