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
        SimpleEntry(date: Date(), reminders: Reminder.SnapshotReminders(), settings: SettingManager.getFromUserDefaults())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let dayModels = DayModelManager.syncFromUserDefaults()
        let settings = SettingManager.getFromUserDefaults()

        var result = Reminder.SnapshotReminders()
        
        if let reminders = dayModels.first(where: { $0.id == Date().startOfDay })?.reminders, !reminders.isEmpty {
            result = reminders
        }
                
        let entry = SimpleEntry(date: .now, reminders: result, settings: settings)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        let dayModels = DayModelManager.syncFromUserDefaults()
        let settings = SettingManager.getFromUserDefaults()
        
        var result: [Reminder] = []
        
        if let reminders = dayModels.first(where: { $0.id == Date().startOfDay })?.reminders {
            result = reminders
        }
                
        let entry = SimpleEntry(date: .now.endOfDay, reminders: result, settings: settings)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}
