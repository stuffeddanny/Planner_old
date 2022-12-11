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
            Content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } label: {
            days
        }
        .widgetURL(URL(string: "planner://reminder/\(entry.reminders.first?.id.uuidString ?? "nil")"))
    }
    
    @ViewBuilder
    private var Content: some View {
        if !entry.reminders.isEmpty {
            VStack(alignment: .leading, spacing: 5) {

                ForEach(entry.reminders.filter({ !$0.completed }).prefix(2)) { reminder in
                    
                    Divider()
                    HStack {
                        Circle()
                            .strokeBorder(reminder.completed ? settingManager.settings.accentColor : Color.secondary, lineWidth: 1.5)
                            .background(
                                Circle().foregroundColor(reminder.completed ? settingManager.settings.accentColor : Color.clear)
                                    .padding(4)
                            )
                            .frame(width: 17, height: 17)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(reminder.headline)
                                .font(.footnote)
                            
                            if !reminder.note.isEmpty {
                                Text(reminder.note)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .lineLimit(1)
                        
                    }
                    
                }

            }
            .frame(maxHeight: .infinity, alignment: .top)
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text("No reminders for today")
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var days: some View {
        LazyVGrid(columns: .init(repeating: GridItem(), count: 7)) {
            ForEach(daysForCurrentWeek) { day in
                VStack(spacing: 0) {
                    Text(day.id.weekdaySymbol())
                        .foregroundColor(day.id.weekdaySymbol() == "Sat" || day.id.weekdaySymbol() == "Sun" ? settingManager.settings.weekendsColor : .secondary)
                    
                    Text(day.id.day)
                        .foregroundColor(day.id.isToday() ? settingManager.settings.isTodayInverted ? .primary : .theme.primaryOpposite : .primary)
                        .padding(7)
                        .background {
                            if day.id.isToday() {
                                Circle()
                                    .foregroundColor(settingManager.settings.todaysDayColor)
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
        MediumSizeView(entry: SimpleEntry(date: .now, reminders:
                                            [
                                                Reminder(completed: false, headline: "Buy chicken", note: "Lidl"),
                                                Reminder(completed: false, headline: "Buy cola", note: "Lidl"),
                                                Reminder(completed: false, headline: "RentRoom", note: "dawdaw")
                                            ]))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environmentObject(manager)
    }
}
