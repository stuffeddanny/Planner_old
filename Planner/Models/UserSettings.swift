//
//  UserSettings.swift
//  Planner
//
//  Created by Danny on 11/28/22.
//

import SwiftUI

struct UserSettings: Codable {
    var accentColor: Color = Color(.sRGB, red: 1, green: 0.396, blue: 0.392, opacity: 1)
    var selectedDayColor: Color = Color(.sRGB, red: 1, green: 0.396, blue: 0.392, opacity: 1)
    var weekendsColor: Color = .red
    var backgroundColor: Color = .clear
    var todaysDayColor: Color = .primary
    var isTodayInverted: Bool = false
    var isSelectedDayInverted: Bool = false
    var gapBetweenDays: Int = 20
    var tags: [Tag] = [
        Tag(text: "Work", color: .blue),
        Tag(text: "Study", color: .green)
    ]
}


