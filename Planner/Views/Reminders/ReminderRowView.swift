//
//  ReminderRowView.swift
//  Planner
//
//  Created by Danny on 12/1/22.
//

import SwiftUI

struct ReminderRowView: View {
    @FocusState private var focused: Bool
    @EnvironmentObject private var vm: ReminderListViewModel
    @EnvironmentObject private var settingManager: SettingManager

    
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
                TextField("", text: $reminder.headline, axis: .vertical)
                    .focused($focused)
                    .submitLabel(.return)
                    .onSubmit {
                        print("Submont")
                    }

                TextField("Note", text: $reminder.note, axis: .vertical)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .submitLabel(.return)

            }
        }
        .onChange(of: reminder) { newValue in
            vm.update(newValue)
        }
        .onAppear {
            focused = true
        }
    }
}

struct ReminderRowView_Previews: PreviewProvider {
    
    @State static private var completed: Bool = false
    
    static var previews: some View {
//        List {
            ReminderRowView(reminder: Reminder(headline: "Reminder"))
//        }
        .environmentObject(ReminderListViewModel(for: DayModel(id: .now)))
        .environmentObject(SettingManager())
//        .listStyle(.inset)
    }
}
