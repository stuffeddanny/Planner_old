//
//  ReminderListViewModel.swift
//  Planner
//
//  Created by Danny on 12/7/22.a
//

import SwiftUI
import CloudKit
import WidgetKit

final class ReminderListViewModel: ObservableObject {
    
    @Published var reminders: [Reminder] {
        didSet {
            if let index = CloudKitManager.instance.dayModels.firstIndex(where: { $0.id == dayModel.id }) {
                CloudKitManager.instance.dayModels[index].reminders = reminders
            } else {
                CloudKitManager.instance.dayModels.append(DayModel(id: dayModel.id, reminders: reminders))
            }
        }
    }
    
    let dayModel: DayViewModel
    
    init(_ day: DayViewModel) {
        dayModel = day
        
        reminders = CloudKitManager.instance.dayModels.first(where: { $0.id == day.id })?.reminders ?? []
    }
    
    func refresh() async {
        print("\(dayModel.id)")
        
            switch await CloudKitManager.instance.getFromCloudWith(id: dayModel.id) {
            case .success(let dayModel):
                if let reminders = dayModel?.reminders {
                    await MainActor.run {
                        self.reminders = reminders
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
