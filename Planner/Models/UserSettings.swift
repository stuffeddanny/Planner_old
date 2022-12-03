//
//  UserSettings.swift
//  Planner
//
//  Created by Danny on 11/28/22.
//

import SwiftUI

struct UserSettings: Codable {
    var accentColor: Color = .theme.accent
    var selectedDayColor: Color = .theme.accent
    var weekendsColor: Color = .red
    var backgroundColor: Color = .clear
    var todaysDayColor: Color = .red
    var isTodayInverted: Bool = false
    var isSelectedDayInverted: Bool = false
    var gapBetweenDays: Int = 20
    var tags: [Tag] = [
        Tag(text: "Work", color: .blue),
        Tag(text: "Study", color: .green)
    ]
}


