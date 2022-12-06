//
//  CalendarViewModel.swift
//  Planner
//
//  Created by Danny on 11/26/22.
//

import SwiftUI
import Combine

final class CalendarViewModel: ObservableObject {
        
    @Published var firstDayOfUnitOnTheScreenDate: Date {
        didSet {
            if weekView {
                days = firstDayOfUnitOnTheScreenDate.getDayModelsForWeek()
            } else {
                days = firstDayOfUnitOnTheScreenDate.getDayModelsForMonth()
            }
        }
    }
    @Published var offset = CGSize()
    @Published var opacity: Double = 1
    var monthName: String {
        firstDayOfUnitOnTheScreenDate.month
    }
    var yearName: String {
        firstDayOfUnitOnTheScreenDate.year
    }
        
    @Published var weekView: Bool = false
    @Published var days: [DayModel]
    @Published var selectedDay: DayModel? = nil {
        didSet {
            if let day = selectedDay {
                Task {
                    
                    let reminders = await RemindersFromUserDefaultsManager.instance.getReminders(for: day) ?? []
                                        
                    await MainActor.run {
                        remindersOnTheScreen = reminders.filter({ !$0.completed && !$0.headline.isEmpty })
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + DevPrefs.daySelectingAnimationDuration + DevPrefs.weekHighlightingAnimationDuration) { [weak self] in
                    if let self = self {
                        withAnimation(DevPrefs.noteAppearingAnimation) {
                            self.showNote = self.weekView
                        }
                    }
                }
            } else {
                showNote = false
            }
        }
    }
    @Published var showNote: Bool = false
    
    @Published var remindersOnTheScreen: [Reminder] = []

    init() {
        let date = Date().startOfMonth
        firstDayOfUnitOnTheScreenDate = date
        days = date.getDayModelsForMonth()
    }
    
    func delete(_ reminder: Reminder) {
        withAnimation {
            remindersOnTheScreen.removeAll(where: { $0.id == reminder.id })
        }
    }
    
    func delete(in set: IndexSet) {
        let idsToDelete = set.map { remindersOnTheScreen[$0].id }
        
        _ = idsToDelete.compactMap { [weak self] id in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self?.remindersOnTheScreen.removeAll(where: { $0.id == id })
            }
        }
    }
    
    func createNewReminder(after reminder: Reminder? = nil) {
        let newReminder = Reminder()
        
        withAnimation {
            if let reminder = reminder, let index = remindersOnTheScreen.firstIndex(of: reminder) {
                remindersOnTheScreen.insert(newReminder, at: index + 1)
            } else {
                remindersOnTheScreen.append(newReminder)
            }
        }
    }
    
    func moveReminder(fromOffsets: IndexSet, toOffset: Int) {
        remindersOnTheScreen.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    func update(_ reminder: Reminder) {
        if let index = remindersOnTheScreen.firstIndex(where: { $0.id == reminder.id }) {
            remindersOnTheScreen[index] = reminder
            if let day = selectedDay {
                Task {
                    await RemindersFromUserDefaultsManager.instance.set(remindersOnTheScreen, for: day)
                }
            }
        }
     }
    
    func select(_ day: DayModel) {
        withAnimation(DevPrefs.daySelectingAnimation) {
            selectedDay = day
            DispatchQueue.main.asyncAfter(deadline: .now() + DevPrefs.daySelectingAnimationDuration) {
                withAnimation(DevPrefs.weekHighlightingAnimation) { [weak self] in
                    self?.weekView = true
                    self?.firstDayOfUnitOnTheScreenDate = day.id.startOfDay
                    
                }
            }
        }
    }
    
    func unselect() {
        let wasSelected = selectedDay != nil
        if wasSelected {
            withAnimation(DevPrefs.daySelectingAnimation) {
                selectedDay = nil
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (wasSelected ? DevPrefs.daySelectingAnimationDuration : 0)) { [weak self] in
            withAnimation(DevPrefs.weekHighlightingAnimation) {
                self?.dismissWeekView()
            }
        }

    }
    
    private func dismissWeekView() {
        weekView = false
        firstDayOfUnitOnTheScreenDate = firstDayOfUnitOnTheScreenDate.startOfMonth
    }
    
    func isDaySelected(_ day: DayModel) -> Bool {
        selectedDay == day
    }
    
    func isToday(_ day: DayModel) -> Bool {
        return Calendar.current.isDate(day.id, equalTo: .now, toGranularity: .day)
    }
    
    func goTo(_ date: Date) {
        if (weekView && !Date.isSameWeek(firstDayOfUnitOnTheScreenDate, date)) || !Calendar.current.isDate(firstDayOfUnitOnTheScreenDate, equalTo: date, toGranularity: .month) {
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
