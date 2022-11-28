//
//  UserSettings.swift
//  Planner
//
//  Created by Danny on 11/28/22.
//

import SwiftUI

struct UserSettings: Codable {
    var accentColor: Color
    var selectedDayColor: Color
    var weekendsColor: Color
    var backgroundColor: Color
    var todaysDayColor: Color
    var isTodayInverted, isSelectedDayInverted: Bool
    
    init(accentColor: Color = Color.theme.accent, selectedDayColor: Color = Color.theme.accent, weekendsColor: Color = .red, backgroundColor: Color = .clear, todaysDayColor: Color = .red, isTodayInverted: Bool = false, isSelectedDayInverted: Bool = false) {
        self.accentColor = accentColor
        self.selectedDayColor = selectedDayColor
        self.weekendsColor = weekendsColor
        self.backgroundColor = backgroundColor
        self.todaysDayColor = todaysDayColor
        self.isTodayInverted = isTodayInverted
        self.isSelectedDayInverted = isSelectedDayInverted
    }
}


