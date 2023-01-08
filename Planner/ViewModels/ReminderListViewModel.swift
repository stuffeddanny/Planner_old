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
    
    @Published var reminders: [Reminder]
    
    @Published var isSyncing: Bool = false
    @Published var syncError: LocalizedAlertError? = nil

    let dayModel: DayViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private func setToDayModelManager() {
        if let index = DayModelManager.instance.dayModels.firstIndex(where: { $0.id == dayModel.id }) {
            var newDayModel = dayModelManager.dayModels[index]
            newDayModel.reminders = reminders
            newDayModel.dateModified = .now

            dayModelManager.dayModels[index] = newDayModel

        } else {
            DayModelManager.instance.dayModels.append(DayModel(id: dayModel.id, reminders: reminders, dateModified: .now))
        }
    }
    
    init(_ day: DayViewModel) {
        dayModel = day
        
        reminders = dayModelManager.dayModels.first(where: { $0.id == day.id })?.reminders ?? []
        
        dayModelManager.$dayModels
            .sink { newValue in
                if let reminders = newValue.first(where: {$0.id == day.id})?.reminders {
                    DispatchQueue.main.async {
                        self.reminders = reminders
                    }
                }
            }
            .store(in: &cancellables)
        
        dayModelManager.$isSyncing
            .sink { isSyncing in
                DispatchQueue.main.async {
                    self.isSyncing = isSyncing
                }
            }
            .store(in: &cancellables)
        
        dayModelManager.$syncError
            .sink { syncError in
                DispatchQueue.main.async {
                    self.syncError = syncError
                }
            }
            .store(in: &cancellables)
    }
    
//    func refresh() async {
//        switch await CloudManager.instance.getFromCloudWith(id: dayModel.id) {
//        case .success(let dayModel):
//            await MainActor.run {
//                withAnimation {
//                    syncError = nil
//                    self.reminders = dayModel.reminders
//                }
//            }
//        case .failure(_):
//            await MainActor.run {
//                syncError = .init(error: CustomError.noInternet)
//            }
//        }
//    }

    func delete(in set: IndexSet) {
        let idsToDelete = set.map { reminders[$0].id }

        _ = idsToDelete.compactMap { [weak self] id in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                NotificationManager.instance.removePendingNotification(with: idsToDelete)
                self?.reminders.removeAll(where: { $0.id == id })
                self?.setToDayModelManager()
                self?.dayModelManager.setToCloudSubject.send()
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
            setToDayModelManager()
            dayModelManager.setToCloudSubject.send()
        }
    }

    func moveReminder(fromOffsets: IndexSet, toOffset: Int) {
        reminders.move(fromOffsets: fromOffsets, toOffset: toOffset)
        setToDayModelManager()
        dayModelManager.setToCloudSubject.send()
    }
    
    func update(_ newValue: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == newValue.id }),
        reminders[index] != newValue {
            var newValueUpdated = newValue
            newValueUpdated.dateModified = .now
            reminders[index] = newValueUpdated
            setToDayModelManager()
            dayModelManager.setToCloudSubject.send()
        }
    }
}
