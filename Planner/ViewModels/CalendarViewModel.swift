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
    
    @Published var showReminder: Bool = false
    
    var days: [DayViewModel] {
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
    
    
    @Published var selectedDay: DayViewModel? = nil {
        didSet {
            if let id = selectedDay?.id {
                remindersOnTheScreen = dayModels.first(where: { $0.id == id })?.reminders ?? []
            } else {
                remindersOnTheScreen = []
            }
            
        }
    }
    
    @Published var remindersOnTheScreen: [Reminder] = [] {
        didSet {
            if let id = selectedDay?.id {
                if let index = dayModels.firstIndex(where: { $0.id == id }) {
                    dayModels[index].reminders = remindersOnTheScreen
                } else {
                    dayModels.append(DayModel(id: id, reminders: remindersOnTheScreen))
                }
            }
        }
    }
    
    @Published private var syncPublisher: [DayModel] = []
    
    
    var dayModels: [DayModel] {
        get {
            let data = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "dayModels") ?? .init()
            
            let holder = try? JSONDecoder().decode(DayModelsHolder.self, from: data)
            
            return holder?.models ?? []
        }
        set {
            
            syncPublisher = newValue
            
            if let defaults = UserDefaults(suiteName: "group.plannerapp"),
               let encoded = try? JSONEncoder().encode(DayModelsHolder(models: newValue)) {
                defaults.set(encoded, forKey: "dayModels")
            }
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
 
    init() {
                
        let date = Date().startOfMonth
        
        firstDayOfUnitOnTheScreenDate = date
        
        $syncPublisher
            .dropFirst()
            .debounce(for: .seconds(DevPrefs.syncDebounce), scheduler: DispatchQueue.main)
            .sink { newValue in
                Task {
                    await self.syncToCloud(newValue)
                }

            }
            .store(in: &cancellables)
    }
    
    private func syncFromCloud() async -> Result<Void, Never> {
        await withCheckedContinuation { continuation in
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "DayModel", predicate: predicate)
            
            CKContainer.default().privateCloudDatabase.fetch(withQuery: query) { result in
                switch result {
                case .success(let returnedValue):
                    let records = returnedValue.matchResults.compactMap { value in
                        switch value.1 {
                        case .success(let record):
                            return record
                        case .failure(_):
                            return nil
                        }
                    }
                    
                    let dayModels = records.compactMap { record in
                        if let id = Date.dateFromId(record.recordID.recordName),
                           let encodedReminders = record["reminders"] as? [Data] {
                            let reminders = encodedReminders.compactMap({ try? JSONDecoder().decode(Reminder.self, from: $0)})
                            return DayModel(id: id, reminders: reminders)
                        } else {
                            return nil
                        }
                    }
                    
                    self.dayModels = dayModels
                                        
                    continuation.resume(returning: .success(()))
                    
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func syncToCloud(_ value: [DayModel]) async {
        try? await CKContainer.default().privateCloudDatabase.modifyRecords(saving: value.filter({ !$0.reminders.isEmpty }).map({ $0.record }), deleting: value.filter({ $0.reminders.isEmpty }).map({ $0.record.recordID }), savePolicy: .changedKeys, atomically: false)

    }
    
    func swipeAndGoTo(_ dayModel: DayModel) {
        Task {
            if !Calendar.gregorianWithSunAsFirstWeekday.isDate(firstDayOfUnitOnTheScreenDate, equalTo: dayModel.id, toGranularity: .month) {
                await MainActor.run {
                    goTo(dayModel.id)
                }
                
                
                try await Task.sleep(for: .seconds(DevPrefs.monthSlidingAnimationDuration + DevPrefs.monthAppearingAfterSlidingAnimationDuration))
            }
            
            guard let dayViewModel = days.first(where: { $0.id == dayModel.id }) else { return }

            await MainActor.run {
                select(dayViewModel)
            }
        }
    }
    
    func checkTagsOnExistence(in tags: [Tag]) {

        let daysOfMonth = dayModels.filter({ Calendar.gregorianWithSunAsFirstWeekday.isDate($0.id, equalTo: firstDayOfUnitOnTheScreenDate, toGranularity: .month) })
        
        daysOfMonth.forEach { dayModel in
            let fixedReminders = dayModel.reminders.map { reminder in
                if let tagId = reminder.tagId, !tags.contains(where: { $0.id == tagId}) {
                    var reminder = reminder
                    reminder.tagId = nil
                    return reminder
                }
                return reminder
            }
            
            if dayModel.reminders != fixedReminders, let index = dayModels.firstIndex(of: dayModel) {
                dayModels[index].reminders = fixedReminders
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
    
    func select(_ day: DayViewModel) {
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
