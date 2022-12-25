//
//  ReminderListViewModel.swift
//  Planner
//
//  Created by Danny on 12/7/22.a
//

import SwiftUI
import CloudKit

final class ReminderListViewModel: ObservableObject {
    
    @Binding var reminders: [Reminder]
    let dayModel: DayViewModel
    
    init(_ reminders: Binding<[Reminder]>, _ day: DayViewModel) {
        self._reminders = reminders.projectedValue
        dayModel = day
        print("init \(dayModel.id)")

    }
    
//    func delete(_ reminder: Reminder) {
//        withAnimation {
//            reminders.removeAll(where: { $0.id == reminder.id })
//        }
//    }
    
    
    func refresh() async {
        print("ref \(dayModel.id)")
        switch await getInManager(id: dayModel.id) {
        case .success(let reminders):
            if let reminders = reminders {
                await MainActor.run {
                    self.reminders = reminders
                }
            }
        case .failure(_):
            #warning("Handle")
            break
        }
    }
    
    #warning("Put in the manager")
    private func getInManager(id: Date) async -> Result<[Reminder]?, Error> {
        print("get \(id)")

        return await withCheckedContinuation { continuation in
            CKContainer.default().privateCloudDatabase.fetch(withRecordID: .init(recordName: id.idFromDate)) { returnedRecord, error in
                if let error = error {
                    continuation.resume(returning: .failure(error))
                } else if let record = returnedRecord,
                          let encodedReminders = record["reminders"] as? [Data] {
                    continuation.resume(returning: .success(encodedReminders.compactMap({ try? JSONDecoder().decode(Reminder.self, from: $0) })))
                } else {
                    #warning("Fix")
                    continuation.resume(returning: .success(nil))
                }
            }
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
