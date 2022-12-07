//
//  RemindersFromUserDefaultsManager.swift
//  Planner
//
//  Created by Danny on 12/1/22.
//

import SwiftUI

actor RemindersFromUserDefaultsManager {
    
    static let instance = RemindersFromUserDefaultsManager()
    
    private init() {}
        
    nonisolated func getReminders() -> [DayModel.ID : [Reminder]]? {
                
        let data = UserDefaults.standard.data(forKey: "reminders") ?? .init()
        
        let dict = try? JSONDecoder().decode(RemindersDictionary.self, from: data)
        
        return dict?.reminders
    }
    
    nonisolated func set(_ reminders: [Reminder], for day: DayModel) {
        
        let data = UserDefaults.standard.data(forKey: "reminders") ?? .init()
        
        if var dict = try? JSONDecoder().decode(RemindersDictionary.self, from: data) {
            
            dict.reminders[day.id] = reminders
            
            UserDefaults.standard.set(try? JSONEncoder().encode(dict), forKey: "reminders")
        }
    }
}
