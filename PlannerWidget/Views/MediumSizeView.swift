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
    private let daysForCurrentWeek: [DayViewModel] = Date().getDayModelsForWeek()
    
    var body: some View {
        GroupBox {
            Content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } label: {
            days
        }
        .widgetURL(URL(string: "planner://day"))
    }
    
    @ViewBuilder
    private var Content: some View {
        if !entry.reminders.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                
                ForEach(entry.reminders.filter({ !$0.completed }).prefix(3)) { reminder in
                    
                    Divider()
                    
                    Link(destination: URL(string: "planner://reminder/\(reminder.id.uuidString)")!) {
                        HStack {
                            Circle()
                                .strokeBorder(reminder.completed ? entry.settings.accentColor : Color.secondary, lineWidth: 1.5)
                                .background(
                                    Circle().foregroundColor(reminder.completed ? entry.settings.accentColor : Color.clear)
                                        .padding(4)
                                )
                                .frame(width: 17, height: 17)
                            
                            Text(reminder.headline)
                            
                            Spacer(minLength: 0)
                            
                            if let date = reminder.date {
                                Text(date.formattedToTimeFormat())
                                    .foregroundColor(Date.compareDates(date1: .now, date2: date) && !reminder.completed ? .red : .secondary)
                            }
                            
                            if let tagId = reminder.tagId {
                                Circle()
                                    .frame(width: 7, height: 7)
                                    .foregroundColor(getTagColor(for: tagId))
                            }
                            
                        }
                        .font(.footnote)
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
    
    private func getTagColor(for id: UUID) -> Color {
        entry.settings.tags.first(where: { $0.id == id })?.color ?? .clear
    }
    
    @ViewBuilder
    private var days: some View {
        LazyVGrid(columns: .init(repeating: GridItem(), count: 7)) {
            ForEach(daysForCurrentWeek) { day in
                VStack(spacing: 0) {
                    Text(day.id.weekdaySymbol())
                        .foregroundColor(day.id.weekdaySymbol() == "Sat" || day.id.weekdaySymbol() == "Sun" ? entry.settings.weekendsColor : .secondary)
                    
                    Text(day.id.day)
                        .foregroundColor(day.id.isToday() ? entry.settings.isTodayInverted ? .primary : .theme.primaryOpposite : .primary)
                        .padding(7)
                        .background {
                            if day.id.isToday() {
                                Circle()
                                    .foregroundColor(entry.settings.todaysDayColor)
                            }
                        }
                }
                .lineLimit(1)
                .font(.caption.weight(.semibold))
            }
        }
    }
}

struct MediumSizeView_Previews: PreviewProvider {
    static var previews: some View {
        MediumSizeView(entry: .init(date: .now, reminders: [], settings: SettingManager.getFromUserDefaults()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
