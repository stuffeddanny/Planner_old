//
//  DayView.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

struct DayView: View {
    
    @EnvironmentObject private var settingManager: SettingManager
    
    let isSelected: Bool
    let isToday: Bool
    let dayModel: DayModel
    
    init(for day: DayModel, isSelected: Bool, isToday: Bool) {
        dayModel = day
        self.isSelected = isSelected
        self.isToday = isToday
    }
    
    var body: some View {
        ZStack {
            
            if !dayModel.secondary && (isSelected || isToday) {
               highlight
            }
            
            
            Text("\(dayModel.id.day)")
                .foregroundColor(dayNumberColor())
        }
    }
    
    private var highlight: some View {
        Circle()
            .frame(width: 40, height: 40)
            .foregroundColor(highLightColor())
    }
    
    private func highLightColor() -> Color {
        if isSelected {
            return settingManager.settings.selectedDayColor
        } else if isToday {
            return settingManager.settings.todaysDayColor
        } else {
            return .clear
        }
    }
    
    private func dayNumberColor() -> Color {
        if dayModel.secondary {
            return .secondary
        } else if Calendar.isDateInWeekend(Calendar.current)(dayModel.id) {
            return settingManager.settings.weekendsColor
        } else if isSelected {
            if settingManager.settings.isSelectedDayInverted {
                return .primary
            } else {
                return .theme.primaryOpposite
            }
        } else if isToday {
            if settingManager.settings.isTodayInverted {
                return .primary
            } else {
                return .theme.primaryOpposite
            }
        } else {
            return .primary
        }
    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(for: DayModel(id: .now), isSelected: false, isToday: false)
    }
}
