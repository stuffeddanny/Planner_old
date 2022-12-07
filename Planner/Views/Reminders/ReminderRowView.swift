//
//  ReminderRowView.swift
//  Planner
//
//  Created by Danny on 12/7/22.
//

import SwiftUI

struct ReminderRowView: View {
    @FocusState private var focused: FocusedField?
    
    @EnvironmentObject private var settingManager: SettingManager
    @EnvironmentObject private var vm: ReminderListViewModel
    
    @State private var showCalendarSheet: Bool = false
    @State private var showClockSheet: Bool = false

    @State private var showTags: Bool = false
    
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
            
            if let tagId = reminder.tagId {
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(settingManager.settings.tags.first(where: { $0.id == tagId })?.color ?? .clear)
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
            HStack(spacing: 0) {
                
                Button {
                    showTags.toggle()
                } label: {
                    Image(systemName: "tag")
                }
                
                Image(systemName: "chevron.right")
                    .rotationEffect(showTags ? Angle(degrees: 180) : Angle())
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .animation(.linear(duration: 0.1), value: showTags)
                    .padding(.trailing, 5)
                

                Spacer(minLength: 0)
                
                if showTags {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(settingManager.settings.tags) { tag in
                                TagView(tag: tag, isSelected: tag.id == reminder.tagId)
                                    .frame(height: 27)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if tag.id == reminder.tagId {
                                                reminder.tagId = nil
                                            } else {
                                                reminder.tagId = tag.id
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.never)
                } else {
                    Button {
                        showCalendarSheet = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                    .padding(.trailing)
                    
                    
                    Button {
                        showClockSheet = true
                    } label: {
                        Image(systemName: "clock")
                    }
                    
                }
            }
            .buttonStyle(.borderless)
        }
    }
}
