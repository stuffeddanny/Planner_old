//
//  Provider.swift
//  PlannerWidgetExtension
//
//  Created by Danny on 12/10/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
        
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), reminders: Reminder.SnapshotReminders(), settingManager: SettingManager())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "reminders") ?? .init()
        let dict = try? JSONDecoder().decode(RemindersDictionary.self, from: data)
        
        var result = Reminder.SnapshotReminders()
        
        if let reminders = dict?.reminders[DayModel(id: Date().startOfDay).id], !reminders.isEmpty {
            result = Array(reminders)
        }
                
        let entry = SimpleEntry(date: .now, reminders: result, settingManager: SettingManager())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        let data = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "reminders") ?? .init()
        let dict = try? JSONDecoder().decode(RemindersDictionary.self, from: data)
        
        var result: [Reminder] = []
        
        if let reminders = dict?.reminders[DayModel(id: Date().startOfDay).id] {
            result = Array(reminders)
        }
                
        let entry = SimpleEntry(date: .now.endOfDay, reminders: result, settingManager: SettingManager())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}
