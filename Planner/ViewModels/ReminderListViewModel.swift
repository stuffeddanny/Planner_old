//
//  ReminderListViewModel.swift
//  Planner
//
//  Created by Danny on 12/7/22.a
//

import SwiftUI
import CloudKit
import WidgetKit
import Combine

final class ReminderListViewModel: ObservableObject {
    
    private let dayModelManager = DayModelManager.instance
    
    @Published var reminders: [Reminder] {
        didSet {
            if reminders != oldValue {
                if let index = DayModelManager.instance.dayModels.firstIndex(where: { $0.id == dayModel.id }) {
                    var newDayModels = dayModelManager.dayModels[index]
                    newDayModels.reminders = reminders
                    newDayModels.dateModified = .now

                    dayModelManager.dayModels[index] = newDayModels

                } else {
                    DayModelManager.instance.dayModels.append(DayModel(id: dayModel.id, reminders: reminders, dateModified: .now))
                }
            }
        }
    }
    
    let dayModel: DayViewModel
    
    init(_ day: DayViewModel) {
        dayModel = day
        
        reminders = dayModelManager.dayModels.first(where: { $0.id == day.id })?.reminders ?? []
    }
    
    func refresh() async {
        switch await CloudManager.instance.getFromCloudWith(id: dayModel.id) {
        case .success(let dayModel):
            await MainActor.run {
                withAnimation {
                    self.reminders = dayModel.reminders
                }
            }
        case .failure(_):
            #warning("Handle")
            break
        }
    }

    func delete(in set: IndexSet) {
        let idsToDelete = set.map { reminders[$0].id }

        _ = idsToDelete.compactMap { [weak self] id in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                NotificationManager.instance.removePendingNotification(with: idsToDelete)
                self?.reminders.removeAll(where: { $0.id == id })
            }
        }
    }
    
    func createNewReminder(after reminder: Reminder? = nil) {
        let newReminder = Reminder(dateModified: .now)

        withAnimation {
            if let reminder = reminder, let index = reminders.firstIndex(of: reminder) {
                reminders.insert(newReminder, at: index + 1)
            } else {
                reminders.append(newReminder)
            }
        }
    }

    func moveReminder(fromOffsets: IndexSet, toOffset: Int) {
        reminders.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    func update(_ newValue: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == newValue.id }) {
            var newValueUpdated = newValue
            newValueUpdated.dateModified = .now
            reminders[index] = newValue
        }
    }
}
