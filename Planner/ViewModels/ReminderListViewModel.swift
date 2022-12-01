//
//  ReminderListViewModel.swift
//  Planner
//
//  Created by Danny on 12/1/22.
//

import SwiftUI
import Combine

class ReminderListViewModel: ObservableObject {
    
    @Published var reminders: [Reminder] = []
    
    
    private let dayModel: DayModel
    
    
    init(for day: DayModel) {
        dayModel = day
        
    }
    
    func delete(_ reminder: Reminder) {
        reminders.removeAll(where: { $0.id == reminder.id })
    }
    
    func delete(in set: IndexSet) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.reminders.remove(atOffsets: set)
        }
    }
    
    func createNewReminder() {
        withAnimation {
            reminders.insert(Reminder(), at: 0)
        }
    }
    
    func moveReminder(fromOffsets: IndexSet, toOffset: Int) {
        reminders.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    func update(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        }
     }
}
