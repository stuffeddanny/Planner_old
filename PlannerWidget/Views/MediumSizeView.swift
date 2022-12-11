//
//  MediumSizeView.swift
//  PlannerWidgetExtension
//
//  Created by Danny on 12/10/22.
//

import SwiftUI
import WidgetKit

struct MediumSizeView: View {
    var entry: SimpleEntry
    @EnvironmentObject private var settingManager: SettingManager
    private let daysForCurrentWeek: [DayModel] = Date().getDayModelsForWeek()
    
    var body: some View {
        GroupBox {
            ZStack {
                if !entry.reminders.isEmpty {
//                    VStack(alignment: .leading) {
//                        Text(reminder.headline)
//
//                        Text(reminder.completed ? "Completed" : "Opened")
//
//                    }
                } else {
                    Text("No reminders for today")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } label: {
            days
        }
        .widgetURL(URL(string: "planner://reminder/\(entry.reminders.first?.id.uuidString ?? "nil")"))
    }
    
    @ViewBuilder
    private var days: some View {
        LazyVGrid(columns: .init(repeating: GridItem(), count: 7)) {
            ForEach(daysForCurrentWeek) { day in
                VStack(spacing: 0) {
                    Text(day.id.weekdaySymbol())
                        .foregroundColor(day.id.weekdaySymbol() == "Sat" || day.id.weekdaySymbol() == "Sun" ? settingManager.settings.weekendsColor : .secondary)
                    
                    Text(day.id.day)
                        .padding(7)
                        .background {
                            if day.id.isToday() {
                                Circle()
                                    .foregroundColor(settingManager.settings.accentColor)
                            }
                        }
                }
                .lineLimit(1)
                .font(.caption)
                .fontWeight(.semibold)
                
            }
        }
    }
}


struct WidgetView_Previews: PreviewProvider {
    @StateObject static private var manager = SettingManager()
    
    static var previews: some View {
        MediumSizeView(entry: SimpleEntry(date: .now, reminders: [Reminder(completed: false, headline: "Buy chicken", note: "Lidl")]))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environmentObject(manager)
    }
}
