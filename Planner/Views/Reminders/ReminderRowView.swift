//
//  ReminderRowView.swift
//  Planner
//
//  Created by Danny on 12/7/22.
//

import SwiftUI

class ReminderRowViewModel: ObservableObject {
    @Published var reminder: Reminder
    @Published var notificationsAllowed: Bool? = nil
    @Published var toggle: Bool
    
    init(reminder: Reminder) {
        self.reminder = reminder
        toggle = reminder.date != nil
    }
}

struct ReminderRowView: View {
    
    @State private var selectedDate: Date = .now
        
    private let notificationManager = NotificationManager.instance
    
    @FocusState private var focused: FocusedField?
    
    @StateObject private var settingManager = SettingManager.instance
    @EnvironmentObject private var listVm: ReminderListViewModel
    
    @State private var showClockSheet: Bool = false
    @State private var showTags: Bool = false
    
    enum FocusedField {
        case headline, note
    }
        
    @ObservedObject private var vm: ReminderRowViewModel
    
    init(reminder: Reminder) {
        _vm = .init(wrappedValue: ReminderRowViewModel(reminder: reminder))
    }
    
    
    var body: some View {
        HStack(spacing: 13) {
            ReminderCompletionCircleView(completed: $vm.reminder.completed, color: settingManager.settings.accentColor)
                .frame(width: 25, height: 25) // Circle size
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.06)) {
                        vm.reminder.completed.toggle()
                        HapticManager.instance.impact(style: .light)
                    }
                }
            
            
            // Text column
            VStack(alignment: .leading, spacing: 0) {
                TextField("", text: $vm.reminder.headline, axis: .horizontal)
                    .focused($focused, equals: .headline)
                    .onSubmit {
                        if !vm.reminder.headline.isEmpty {
                            listVm.createNewReminder(after: vm.reminder)
                        }
                    }
                    .foregroundColor(vm.reminder.completed && focused == nil ? .secondary : .primary)
                
                if focused != nil || !vm.reminder.note.isEmpty {
                    TextField("Note", text: $vm.reminder.note, axis: .vertical)
                        .focused($focused, equals: .note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .submitLabel(.return)
                }
                
                if let date = vm.reminder.date {
                    
                    Text(date.formattedToTimeFormat())
                        .foregroundColor(Date.compareDates(date1: .now, date2: date) && !vm.reminder.completed ? .red : .secondary)
                        .font(.caption)
                    
                }
                
            }

            if let tagId = vm.reminder.tagId {
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
                            vm.notificationsAllowed = success
                        case .failure(_):
                            vm.notificationsAllowed = false
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
            if newValue == nil && vm.reminder.headline.isEmpty {
                vm.reminder.headline = "New reminder"
            }
        }
        .onChange(of: vm.reminder) { newValue in
            listVm.update(newValue)
        }
        .task {
            if vm.reminder.justCreated {
                focused = .headline
                vm.reminder.justCreated = false
            }
            
            selectedDate = listVm.dayModel.id
        }
    }
    
    private func setNotification() {
        
        if vm.toggle {
            let content = UNMutableNotificationContent()
            content.title = vm.reminder.headline
            content.subtitle = vm.reminder.note
            content.sound = .default
            content.badge = 1
            
            let components = Calendar.gregorianWithSunAsFirstWeekday.dateComponents([.hour, .minute, .day, .year, .month], from: selectedDate)
            
            notificationManager.scheduleNotification(with: content, identifier: vm.reminder.id, dateComponents: components)
            
            vm.reminder.date = Calendar.gregorianWithSunAsFirstWeekday.date(from: components)
        } else {
            notificationManager.removePendingNotification(with: [vm.reminder.id])
            
            vm.reminder.date = nil
        }
    }
    
    @ViewBuilder
    private var SetNotificationView: some View {
        if let allowed = vm.notificationsAllowed {
            if allowed {
                VStack {
                    
                    Toggle(isOn: $vm.toggle) {
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
                                
                                if vm.toggle {
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
                        .disabled(!vm.toggle)
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
                                TagView(tag: tag, isSelected: tag.id == vm.reminder.tagId)
                                    .frame(height: 27)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            if tag.id == vm.reminder.tagId {
                                                vm.reminder.tagId = nil
                                            } else {
                                                vm.reminder.tagId = tag.id
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
    static let reminder = Reminder(headline: "Reminder", note: "With note", date: .now, dateModified: .now)
    static var previews: some View {
        ReminderRowView(reminder: reminder)
            .environmentObject(ReminderListViewModel(DayViewModel(id: .now)))
    }
}
