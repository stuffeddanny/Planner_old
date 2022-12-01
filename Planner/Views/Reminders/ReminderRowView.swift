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
        HStack {
            ReminderCompletionCircleView(completed: $reminder.completed, color: settingManager.settings.accentColor)
                .frame(width: 25, height: 25) // Circle size
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.06)) {
                        reminder.completed.toggle()
                        HapticManager.instance.impact(style: .light)
                    }
                }
                    
                
            VStack(alignment: .leading, spacing: 0) {
                TextField("", text: $reminder.headline)
                    .focused($focused)
                
                TextField("Note", text: $reminder.note)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

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
        List {
            ReminderRowView(reminder: Reminder())
        }
        .environmentObject(ReminderListViewModel(for: DayModel(id: .now)))
        .environmentObject(SettingManager())
        .listStyle(.inset)
    }
}
