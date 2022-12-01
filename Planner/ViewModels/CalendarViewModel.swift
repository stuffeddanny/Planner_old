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
        
    @Published var weekView: Bool = false {
        didSet {
            if weekView {
                DispatchQueue.main.asyncAfter(deadline: .now() + DevPrefs.weekHighlightingAnimationDuration) { [weak self] in
                    if let self = self {
                        withAnimation(DevPrefs.noteAppearingAnimation) {
                            self.showNote = self.weekView
                        }
                    }
                }
            }
        }
    }
    @Published var days: [DayModel]
    @Published var selectedDay: DayModel? = nil
    @Published var showNote: Bool = false
    
    init() {
        let date = Date().startOfMonth
        firstDayOfUnitOnTheScreenDate = date
        days = date.getDayModelsForMonth()
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
            self?.dismissWeekView()
        }

    }
    
    private func dismissWeekView() {
        withAnimation(DevPrefs.noteAppearingAnimation) {
            showNote = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + DevPrefs.noteAppearingAnimationDuration) {
            withAnimation(DevPrefs.weekHighlightingAnimation) {
                self.weekView = false
                self.firstDayOfUnitOnTheScreenDate = self.firstDayOfUnitOnTheScreenDate.startOfMonth
            }
        }
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
