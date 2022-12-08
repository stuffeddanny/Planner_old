//
//  ReminderRowView.swift
//  Planner
//
//  Created by Danny on 12/7/22.
//

import SwiftUI

struct ReminderRowView: View {
    
    @State private var selectedDate: Date = .now
    @State private var toggle: Bool
    
    @State private var notificationsAllowed: Bool? = nil
    
    private let notificationManager = NotificationManager.instance
    
    @FocusState private var focused: FocusedField?
    
    @EnvironmentObject private var settingManager: SettingManager
    @EnvironmentObject private var vm: ReminderListViewModel
    
    @State private var showClockSheet: Bool = false
    
    @State private var showTags: Bool = false
    
    enum FocusedField {
        case headline, note
    }
    
    @State var reminder: Reminder
    
    init(reminder: Reminder) {
        _reminder = .init(initialValue: reminder)
        _toggle = .init(initialValue: reminder.date != nil)
    }
    
    
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
                    .foregroundColor(reminder.completed && focused == nil ? .secondary : .primary)
                
                if focused != nil || !reminder.note.isEmpty {
                    TextField("Note", text: $reminder.note, axis: .vertical)
                        .focused($focused, equals: .note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .submitLabel(.return)
                }
                
                if let date = reminder.date {
                    
                    Text(date.formattedToTimeFormat())
                        .foregroundColor(compareDates(date1: .now, date2: date) && !reminder.completed ? .red : .secondary)
                        .font(.caption)
                    
                }
                
            }

            if let tagId = reminder.tagId {
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(settingManager.settings.tags.first(where: { $0.id == tagId })?.color ?? .clear)
            }
        }
        .sheet(isPresented: $showClockSheet, onDismiss: setNotification, content: {
            SetNotificationView
                .onAppear {
                    NotificationManager.instance.requestAuthorization { result in
                        switch result {
                        case .success(let success):
                            notificationsAllowed = success
                        case .failure(_):
                            notificationsAllowed = false
                        }
                    }
                }
            .presentationDetents([.height(300)])
        })
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
            
            if !Calendar.current.isDate(vm.dayModel.id, equalTo: .now, toGranularity: .day) {
                selectedDate = vm.dayModel.id
            }
        }
    }
    
    private func compareDates(date1: Date, date2: Date) -> Bool {
        if Calendar.current.compare(date1, to: date2, toGranularity: .minute).rawValue == 1 {
            return true
        }
        
        return false
    }
    
    private func setNotification() {
        
        if toggle {
            let content = UNMutableNotificationContent()
            content.title = reminder.headline
            content.subtitle = reminder.note
            content.sound = .default
            content.badge = 1
            
            let components = Calendar.current.dateComponents([.hour, .minute, .day, .year, .month], from: selectedDate)
            
            notificationManager.scheduleNotification(with: content, identifier: reminder.id, dateComponents: components)
            
            reminder.date = Calendar.current.date(from: components)
        } else {
            notificationManager.removePendingNotification(with: [reminder.id])
            
            reminder.date = nil
        }
    }
    
    @ViewBuilder
    private var SetNotificationView: some View {
        if let allowed = notificationsAllowed {
            if allowed {
                VStack {
                    
                    Toggle(isOn: $toggle) {
                        HStack {
                            ZStack {
                                Rectangle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                                    .cornerRadius(5)
                                
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.white)
                                
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Time")
                                
                                if toggle {
                                    Text(selectedDate.formattedToTimeFormat())
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                        }
                    }
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .disabled(!toggle)
                }
                .padding()
                .padding(.top)
            } else {
                Text("Sorry but app has no access to send you notification.\nCheck Settings > Planner > Notifications")
                    .multilineTextAlignment(.center)
            }
        } else {
            Text("Checking notification permission...")
            
            ProgressView()
                .padding()
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

struct ReminderRowView_Previews: PreviewProvider {
    static let reminder = Reminder(headline: "Reminder", note: "With note", date: .now)
    static var previews: some View {
        ReminderRowView(reminder: reminder)
            .environmentObject(SettingManager())
            .environmentObject(ReminderListViewModel(.constant([reminder]), DayModel(id: .now)))
    }
}
