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
}

struct ReminderRowView_Previews: PreviewProvider {
    
    @State static private var completed: Bool = false
    
    static var previews: some View {
//        List {
            ReminderRowView(reminder: Reminder(headline: "Reminder"))
//        }
        .environmentObject(CalendarViewModel())
        .environmentObject(SettingManager())
//        .listStyle(.inset)
    }
}
