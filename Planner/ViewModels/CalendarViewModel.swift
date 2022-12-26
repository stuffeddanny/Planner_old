//
//  CalendarViewModel.swift
//  Planner
//
//  Created by Danny on 12/7/22.
//

import SwiftUI
import Combine
import CloudKit
import WidgetKit

final class CalendarViewModel: ObservableObject {
    var monthName: String {
        firstDayOfUnitOnTheScreenDate.month
    }
    var yearName: String {
        firstDayOfUnitOnTheScreenDate.year
    }
    
    @Published var firstDayOfUnitOnTheScreenDate: Date
    @Published var weekView: Bool = false
    
    @Published var showReminderList: Bool = false
    
    var days: [DayViewModel] {
        if weekView {
            return firstDayOfUnitOnTheScreenDate.getDayModelsForWeek()
        } else {
            return firstDayOfUnitOnTheScreenDate.getDayModelsForMonth()
        }    
    }
    @Published var offset = CGSize()
    @Published var opacity: Double = 1
    
    
    @Published var selectedDay: DayViewModel? = nil
    
    init() {
                
        let date = Date().startOfMonth
        
        firstDayOfUnitOnTheScreenDate = date
    }
        
    func swipeAndGoTo(_ id: DayModel.ID) {
        Task {
            if weekView {
                
            } else {
                if !Calendar.gregorianWithSunAsFirstWeekday.isDate(firstDayOfUnitOnTheScreenDate, equalTo: id, toGranularity: .month) {
                    await MainActor.run {
                        goTo(id)
                    }
                    
                    
                    try await Task.sleep(for: .seconds(DevPrefs.monthSlidingAnimationDuration + DevPrefs.monthAppearingAfterSlidingAnimationDuration))
                }
                
                guard let dayViewModel = days.first(where: { $0.id == id }) else { return }
                
                await MainActor.run {
                    select(dayViewModel)
                }
            }
        }
    }
    
    func isDaySelected(_ day: DayViewModel) -> Bool {
        if let selectedDay = selectedDay {
            return selectedDay.id == day.id
        }
        return false
    }
        
    func isToday(_ day: DayViewModel) -> Bool {
        Calendar.gregorianWithSunAsFirstWeekday.isDate(day.id, equalTo: .now, toGranularity: .day)
    }

    func unselect() {
        Task {
            let wasSelected = selectedDay != nil
            if wasSelected {
                await MainActor.run {
                    withAnimation(DevPrefs.daySelectingAnimation) {
                        selectedDay = nil
                    }
                    showReminderList = false
                }
            }
            
            try? await Task.sleep(for: .seconds(wasSelected ? DevPrefs.daySelectingAnimationDuration : 0))
            
            await MainActor.run {
                withAnimation(DevPrefs.weekHighlightingAnimation) {
                    dismissWeekView()
                }
            }
        }
    }
    
    private func dismissWeekView() {
        weekView = false
        firstDayOfUnitOnTheScreenDate = firstDayOfUnitOnTheScreenDate.startOfMonth
    }
    
    func select(_ day: DayViewModel) {
        Task {
            await MainActor.run {
                withAnimation(DevPrefs.daySelectingAnimation) {
                    selectedDay = day
                }
            }
            
            try? await Task.sleep(for: .seconds(DevPrefs.daySelectingAnimationDuration))
              
            if !weekView {
                await MainActor.run {
                    withAnimation(DevPrefs.weekHighlightingAnimation) {
                        firstDayOfUnitOnTheScreenDate = day.id.startOfWeekInMonth
                        weekView = true
                        
                    }
                }
                
                try? await Task.sleep(for: .seconds(DevPrefs.weekHighlightingAnimationDuration))
            }
              
            if !showReminderList {
                await MainActor.run {
                    withAnimation(DevPrefs.noteAppearingAnimation) {
                        showReminderList = true
                        
                    }
                }
            }
        }
    }
    
    func goTo(_ date: Date) {
        if (weekView && !Date.isSameWeek(firstDayOfUnitOnTheScreenDate, date)) || !Calendar.gregorianWithSunAsFirstWeekday.isDate(firstDayOfUnitOnTheScreenDate, equalTo: date, toGranularity: .month) {
            withAnimation(DevPrefs.monthSlidingAnimation) {
                offset = CGSize(width: UIScreen.main.bounds.size.width * (date < firstDayOfUnitOnTheScreenDate ? 1 : -1), height: 0)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + (DevPrefs.monthSlidingAnimationDuration)) {

                self.firstDayOfUnitOnTheScreenDate = self.weekView ? date.startOfWeekInMonth : date.startOfMonth
                self.selectedDay = nil

                self.opacity = 0
                self.offset = CGSize()
                withAnimation(DevPrefs.monthAppearingAfterSlidingAnimation) {
                    self.opacity = 1
                }
            }
        }
    }


}
