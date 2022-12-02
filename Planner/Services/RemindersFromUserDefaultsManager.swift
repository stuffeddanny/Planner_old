//
//  RemindersFromUserDefaultsManager.swift
//  Planner
//
//  Created by Danny on 12/1/22.
//

import SwiftUI

actor RemindersFromUserDefaultsManager {
    
    static let instance = RemindersFromUserDefaultsManager()
    
    private init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        self.formatter = formatter
    }
    
    private let formatter: DateFormatter
    
    func getReminders(for day: DayModel) -> [Reminder]? {
        
        let key = formatter.string(from: day.id)
        
        let data = UserDefaults.standard.data(forKey: key) ?? .init()
        
        return try? JSONDecoder().decode([Reminder].self, from: data)
    }
    
    func set(_ reminders: [Reminder], for day: DayModel) {
        
        let key = formatter.string(from: day.id)
        
        UserDefaults.standard.set(try? JSONEncoder().encode(reminders), forKey: key)
    }
}
