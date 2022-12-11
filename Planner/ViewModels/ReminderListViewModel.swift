//
//  ReminderListViewModel.swift
//  Planner
//
//  Created by Danny on 12/7/22.a
//

import SwiftUI

final class ReminderListViewModel: ObservableObject {
    
    @Binding var reminders: [Reminder]
    let dayModel: DayModel
    
    init(_ reminders: Binding<[Reminder]>, _ day: DayModel) {
        self._reminders = reminders.projectedValue
        dayModel = day
    }
    
//    func delete(_ reminder: Reminder) {
//        withAnimation {
//            reminders.removeAll(where: { $0.id == reminder.id })
//        }
//    }

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
        let newReminder = Reminder()

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
            reminders[index] = newValue
        }
    }
}
