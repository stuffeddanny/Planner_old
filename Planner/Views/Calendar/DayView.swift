//
//  DayView.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

struct DayView: View {
    
    @EnvironmentObject private var settingManager: SettingManager
    
    let dayModel: DayModel
    let isSelected: Bool
    let isToday: Bool
    let colors: [Color]
    
    init(for day: DayModel, isSelected: Bool, isToday: Bool, with colors: [Color]) {
        dayModel = day
        self.isSelected = isSelected
        self.isToday = isToday
        self.colors = colors
    }
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                
                Highlight
                
                Text("\(dayModel.id.day)")
                    .foregroundColor(dayNumberColor())
            }
            
            if !dayModel.secondary {
                Tags
            }
        }
    }
    
    @ViewBuilder
    private var Tags: some View {
        if !colors.isEmpty {
            if settingManager.settings.gapBetweenDays/colors.count > 1 {
                VStack(spacing: 0) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(color)
                    }
                    .frame(maxHeight: CGFloat(settingManager.settings.gapBetweenDays / colors.count), alignment: .top)
                }
                .frame(maxHeight: 30 * CGFloat(colors.count), alignment: .top)
            } else {
                HStack(spacing: 0) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(color)
                    }
                    .frame(maxWidth: CGFloat(20 / colors.count))
                }
            }
        }
    }
    
    private var Highlight: some View {
        Circle()
            .frame(width: 40, height: 40)
            .foregroundColor(!dayModel.secondary && (isSelected || isToday) ? highLightColor() : .clear)
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
        DayView(for: DayModel(id: .now), isSelected: false, isToday: false, with: [.red, .blue])
            .environmentObject(SettingManager())
    }
}
