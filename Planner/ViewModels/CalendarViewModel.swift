//
//  CalendarViewModel.swift
//  Planner
//
//  Created by Danny on 11/26/22.
//

import SwiftUI

final class CalendarViewModel: ObservableObject {
    @Published var days: [DayModel]
    @Published var selectedDate: Date? = nil
    
    private let date: Date
    
    init(for date: Date) {
        self.date = date
        days = date.getDayModelsForMonth()
    }
    
    
    func select(_ day: DayModel) {
        withAnimation(DevPrefs.daySelectingAnimation) {
            selectedDate = day.id
            DispatchQueue.main.asyncAfter(deadline: .now() + DevPrefs.daySelectingAnimationDuration) {
                withAnimation(DevPrefs.weekHighlightingAnimation) {
                    self.leaveOnlyWeekWith(day)
                }
            }
        }
    }
    
    private func leaveOnlyWeekWith(_ day: DayModel) {
        while true {
            if Array(days.prefix(7)).contains(where: { $0 == day }) {
                days = Array(days.prefix(7))
                return
            } else {
                days.removeFirst(7)
            }
        }
    }
    
    func unselect(_ day: DayModel) {
        withAnimation(DevPrefs.daySelectingAnimation) {
            selectedDate = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + DevPrefs.daySelectingAnimationDuration) {
                withAnimation(DevPrefs.weekHighlightingAnimation) {
                    self.days = self.date.getDayModelsForMonth()
                }
            }
        }
    }
    
    func isDaySelected(_ day: DayModel) -> Bool {
        guard let selectedDay = selectedDate else { return false }
        return Calendar.current.isDate(day.id, equalTo: selectedDay, toGranularity: .day)
    }
    
    func isToday(_ day: DayModel) -> Bool {
        return Calendar.current.isDate(day.id, equalTo: .now, toGranularity: .day)
    }

}
