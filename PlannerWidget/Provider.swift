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
        SimpleEntry(date: Date(), reminders: Reminder.SnapshotReminders(), settingManager: SettingManager.instance)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "dayModels") ?? .init()
        let holder = try? JSONDecoder().decode(DayModelHolder.self, from: data)
        
        var result = Reminder.SnapshotReminders()
        
        if let reminders = holder?.models.first(where: { $0.id == Date().startOfDay })?.reminders, !reminders.isEmpty {
            result = Array(reminders)
        }
                
        let entry = SimpleEntry(date: .now, reminders: result, settingManager: SettingManager.instance)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        let data = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "dayModels") ?? .init()
        let holder = try? JSONDecoder().decode(DayModelHolder.self, from: data)
        
        var result: [Reminder] = []
        
        if let reminders = holder?.models.first(where: { $0.id == Date().startOfDay })?.reminders {
            result = Array(reminders)
        }
                
        let entry = SimpleEntry(date: .now.endOfDay, reminders: result, settingManager: SettingManager.instance)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}
