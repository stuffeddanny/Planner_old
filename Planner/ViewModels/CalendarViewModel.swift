//
//  CalendarViewModel.swift
//  Planner
//
//  Created by Danny on 11/26/22.
//

import SwiftUI

final class CalendarViewModel: ObservableObject {
    @Published var monthName: String
    @Published var yearName: String
    @Published var days: [DayModel]
    @Published var selectedDate: Date? = nil
    
    private let date: Date
    
    init(for date: Date) {
        self.date = date
        monthName = date.month
        yearName = date.year
        days = date.getDays()
    }
    
    func select(_ day: DayModel) {
        withAnimation(DevPrefs.daySelectingAnimation) {
            selectedDate = day.id
            print("Chosen \(String(describing: selectedDate))")
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
                    self.days = self.date.getDays()
                }
            }
        }
    }
    
    func isDaySelected(_ day: DayModel) -> Bool {
        guard let selectedDay = selectedDate else { return false }
        return Calendar.current.isDate(day.id, equalTo: selectedDay, toGranularity: .day)
    }

}
