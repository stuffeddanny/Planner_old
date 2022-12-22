//
//  LargeSizeView.swift
//  PlannerWidgetExtension
//
//  Created by Danny on 12/10/22.
//

import SwiftUI
import WidgetKit

struct LargeSizeView: View {
    var entry: SimpleEntry
    private let daysForCurrentWeek: [DayModel] = Date().getDayModelsForWeek()
    
    var body: some View {
        GroupBox {
            Content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } label: {
            days
        }
    }
    
    private func getTagColor(for id: UUID) -> Color {
        entry.settingManager.settings.tags.first(where: { $0.id == id })?.color ?? .clear
    }
    
    
    @ViewBuilder
    private var Content: some View {
        if !entry.reminders.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                
                ForEach(entry.reminders.filter({ !$0.completed }).prefix(6)) { reminder in
                    
                    Divider()
                    
                    Link(destination: URL(string: "planner://reminder/\(reminder.id.uuidString)")!) {
                        HStack {
                            Circle()
                                .strokeBorder(reminder.completed ? entry.settingManager.settings.accentColor : Color.secondary, lineWidth: 1.5)
                                .background(
                                    Circle().foregroundColor(reminder.completed ? entry.settingManager.settings.accentColor : Color.clear)
                                        .padding(4)
                                )
                                .frame(width: 17, height: 17)
                            
                            VStack(alignment: .leading) {
                                Text(reminder.headline)
                                    .font(.callout)
                                
                                if !reminder.note.isEmpty {
                                    Text(reminder.note)
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                }
                            }
                            .frame(minHeight: 35)
                            
                            Spacer(minLength: 0)
                            
                            if let date = reminder.date {
                                Text(date.formattedToTimeFormat())
                                    .font(.callout)
                                    .foregroundColor(Date.compareDates(date1: .now, date2: date) && !reminder.completed ? .red : .secondary)
                            }
                            
                            if let tagId = reminder.tagId {
                                Circle()
                                    .frame(width: 7, height: 7)
                                    .foregroundColor(getTagColor(for: tagId))
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
                        .foregroundColor(day.id.weekdaySymbol() == "Sat" || day.id.weekdaySymbol() == "Sun" ? entry.settingManager.settings.weekendsColor : .secondary)
                    
                    Text(day.id.day)
                        .foregroundColor(day.id.isToday() ? entry.settingManager.settings.isTodayInverted ? .primary : .theme.primaryOpposite : .primary)
                        .padding(7)
                        .background {
                            if day.id.isToday() {
                                Circle()
                                    .foregroundColor(entry.settingManager.settings.todaysDayColor)
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
