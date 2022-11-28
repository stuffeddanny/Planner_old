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
            
            if isSelected || isToday {
                Circle()
                    .foregroundColor(isSelected ? settingManager.settings.selectedDayColor : isToday ? settingManager.settings.todaysDayColor : .clear)
            }
            
            
            Text("\(dayModel.id.day)")
                .foregroundColor(dayModel.secondary ? .secondary : Calendar.isDateInWeekend(Calendar.current)(dayModel.id) ? settingManager.settings.weekendsColor : isSelected ?
                                 settingManager.settings.isSelectedDayInverted ? .primary : Color.theme.primaryOpposite : isToday ? settingManager.settings.isTodayInverted ? .primary : Color.theme.primaryOpposite : .primary)
        }
    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        DayView(for: DayModel(id: .now), isSelected: false, isToday: false)
    }
}
