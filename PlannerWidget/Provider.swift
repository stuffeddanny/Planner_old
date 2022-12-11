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
        SimpleEntry(date: Date(), reminders: Reminder.SnapshotReminders())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "reminders") ?? .init()
        let dict = try? JSONDecoder().decode(RemindersDictionary.self, from: data)
        
        var result = Reminder.SnapshotReminders()
        
        if let reminders = dict?.reminders[DayModel(id: Date().startOfDay).id], !reminders.isEmpty {
            result = Array(reminders.prefix(5))
        }
                
        let entry = SimpleEntry(date: .now, reminders: result)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        let data = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "reminders") ?? .init()
        let dict = try? JSONDecoder().decode(RemindersDictionary.self, from: data)
        
        var result: [Reminder] = []
        
        if let reminders = dict?.reminders[DayModel(id: Date().startOfDay).id] {
            result = Array(reminders.prefix(5))
        }
                
        let entry = SimpleEntry(date: .now, reminders: result)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}
