//
//  CalendarViewModel.swift
//  Planner
//
//  Created by Danny on 12/7/22.
//

import SwiftUI
import Combine
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
    
    @Published var showReminder: Bool = false
    
    var days: [DayModel] {
        get {
            if weekView {
                return firstDayOfUnitOnTheScreenDate.getDayModelsForWeek()
            } else {
                return firstDayOfUnitOnTheScreenDate.getDayModelsForMonth()
            }
        }
        
        set { }
    }
    @Published var offset = CGSize()
    @Published var opacity: Double = 1
    
    
    @Published var selectedDay: DayModel? = nil {
        didSet {
            if let id = selectedDay?.id {
                remindersOnTheScreen = reminders[id] ?? []
            } else {
                remindersOnTheScreen = []
            }
            
        }
    }
    
    @Published var remindersOnTheScreen: [Reminder] = [] {
        didSet {
            if let id = selectedDay?.id {
                reminders[id] = remindersOnTheScreen
            }
        }
    }
    
    var reminders: [DayModel.ID : [Reminder]] {
        get {
            let data = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "reminders") ?? .init()
            
            let dict = try? JSONDecoder().decode(RemindersDictionary.self, from: data)
            
            return dict?.reminders ?? [:]
        }
        set {
            UserDefaults(suiteName: "group.plannerapp")?.set(try? JSONEncoder().encode(RemindersDictionary(reminders: newValue)), forKey: "reminders")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
 
    init() {
                
        let date = Date().startOfMonth
        
        firstDayOfUnitOnTheScreenDate = date
    }
    
    func swipeAndGoTo(_ reminderDict: Dictionary<DayModel.ID, [Reminder]>.Element) {
        Task {
            if !Calendar.gregorianWithSunAsFirstWeekday.isDate(firstDayOfUnitOnTheScreenDate, equalTo: reminderDict.key, toGranularity: .month) {
                await MainActor.run {
                    goTo(reminderDict.key)
                }
                
                try await Task.sleep(for: .seconds(DevPrefs.monthSlidingAnimationDuration + DevPrefs.monthAppearingAfterSlidingAnimationDuration))
            }
            
            guard let dayModel = days.first(where: { $0.id == reminderDict.key }) else { return }

            await MainActor.run {
                select(dayModel)
            }
        }
    }
    
    func isDaySelected(_ day: DayModel) -> Bool {
        if let selectedDay = selectedDay {
            return selectedDay.id == day.id
        }
        return false
    }
        
    func isToday(_ day: DayModel) -> Bool {
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
                    showReminder = false
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
    
    func select(_ day: DayModel) {
        Task {
            await MainActor.run {
                withAnimation(DevPrefs.daySelectingAnimation) {
                    selectedDay = day
                }
            }
            
            try? await Task.sleep(for: .seconds(DevPrefs.daySelectingAnimationDuration))
              
            await MainActor.run {
                withAnimation(DevPrefs.weekHighlightingAnimation) {
                    firstDayOfUnitOnTheScreenDate = day.id.startOfDay
                    weekView = true
                    
                }
            }
            
            try? await Task.sleep(for: .seconds(DevPrefs.weekHighlightingAnimationDuration))
              
            await MainActor.run {
                withAnimation(DevPrefs.noteAppearingAnimation) {
                    showReminder = true
                    
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

                self.firstDayOfUnitOnTheScreenDate = self.weekView ? date.startOfDay : date.startOfMonth
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
