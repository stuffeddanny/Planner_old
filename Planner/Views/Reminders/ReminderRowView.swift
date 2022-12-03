//
//  ReminderRowView.swift
//  Planner
//
//  Created by Danny on 12/1/22.
//

import SwiftUI
import Combine

struct ReminderRowView: View {
    @FocusState private var focused: FocusedField?

    @EnvironmentObject private var vm: CalendarViewModel
    @EnvironmentObject private var settingManager: SettingManager

    enum FocusedField {
        case headline, note
    }

    @State var reminder: Reminder

    
    var body: some View {
        HStack(spacing: 13) {
            ReminderCompletionCircleView(completed: $reminder.completed, color: settingManager.settings.accentColor)
                .frame(width: 25, height: 25) // Circle size
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.06)) {
                        reminder.completed.toggle()
                        HapticManager.instance.impact(style: .light)
                    }
                }
            
            
            // Text column
            VStack(alignment: .leading, spacing: 0) {
                TextField("", text: $reminder.headline, axis: .horizontal)
                    .focused($focused, equals: .headline)
                    .onSubmit {
                        if !reminder.headline.isEmpty {
                            vm.createNewReminder(after: reminder)
                        }
                    }
                
                if focused != nil || !reminder.note.isEmpty {
                    TextField("Note", text: $reminder.note, axis: .vertical)
                        .focused($focused, equals: .note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .submitLabel(.return)
                }
            }
            .foregroundColor(reminder.completed && focused == nil ? .secondary : .primary)
            
            if let tag = reminder.tag {
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(tag.color)
            }
        }
        .toolbar {
            if focused != nil {
                getToolbar()
            }
        }
        .onChange(of: focused) { newValue in
            if newValue == nil && reminder.headline.isEmpty {
                reminder.headline = "New reminder"
            }
        }
        .onChange(of: reminder) { newValue in
            vm.update(newValue)
        }
        .task {
            if reminder.justCreated {
                focused = .headline
                reminder.justCreated = false
            }
        }
    }
    
    @ToolbarContentBuilder
    private func getToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            HStack {
                
                Button {
                    //                    showCalendarSheet = true
                } label: {
                    Image(systemName: "calendar")
                }            .font(.title3)
                
                
                Button {
                    //                    showClockSheet = true
                } label: {
                    Image(systemName: "clock")
                }            .font(.title3)
                
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(settingManager.settings.tags) { tag in
                            TagView(tag: tag, isSelected: tag == reminder.tag)
                                .frame(height: 30)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if tag == reminder.tag {
                                            reminder.tag = nil
                                        } else {
                                            reminder.tag = tag
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            
            .buttonStyle(.borderless)
        }
    }
}

struct ReminderRowView_Previews: PreviewProvider {
    
    @State static private var completed: Bool = false
    
    static var previews: some View {
//        List {
        ReminderRowView(reminder: Reminder(headline: "Reminderda wda 9wdhawdbad advkawdv advada iwvd", note: "dajdhuiawdawba bd adba d ad a dabvd awda daiwdiduabiudbhawdiawdb ab adahidabdw", tag: Tag(text: "someth", color: .pink)))
            .previewLayout(.sizeThatFits)
//        }
        .environmentObject(CalendarViewModel())
        .environmentObject(SettingManager())
//        .listStyle(.inset)
    }
}
