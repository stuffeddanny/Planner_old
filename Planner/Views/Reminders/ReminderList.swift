//
//  ReminderList.swift
//  Planner
//
//  Created by Danny on 12/7/22.
//

import SwiftUI

struct ReminderList: View {
    
    @EnvironmentObject private var settingManager: SettingManager

    @ObservedObject private var vm: ReminderListViewModel
    
    init(for day: DayViewModel) {
        _vm = .init(wrappedValue: ReminderListViewModel(day))
    }
    
    var body: some View {
        NavigationView {
            Content
                .toolbar { getToolbar() }
                .navigationTitle("Reminders (\(vm.reminders.count))")
                .navigationBarTitleDisplayMode(.inline)
                .background(settingManager.settings.backgroundColor)
                .refreshable {
                    await vm.refresh()
                }

        }
    }
    
    @ViewBuilder
    private var Content: some View {
        if !vm.reminders.isEmpty {
                List {
                    ForEach(vm.reminders) { reminder in
                        ReminderRowView(reminder: reminder)
                            .environmentObject(vm)
                    }
                    .onDelete { indexSet in
                        vm.delete(in: indexSet)
                    }
                    .onMove { indexSet, index in
                        vm.moveReminder(fromOffsets: indexSet, toOffset: index)
                    }
                    .listRowBackground(settingManager.settings.backgroundColor)
                }
                .onAppear {
                    NotificationManager.instance.removeDeliveredNotificationsFromNotificationCenter(with: vm.reminders.map({ $0.id }))
                }
                .scrollDismissesKeyboard(.interactively)
                .listStyle(.plain)
        } else {
            ZStack {

                Text("You have no reminders.\nTap here to create one ")
                    .lineSpacing(10)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 30)
            }
            .background(Color.white.opacity(0.000000001)
                .onTapGesture {
                    vm.createNewReminder()
                })
        }
    }
    
    @ToolbarContentBuilder
    private func getToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                vm.createNewReminder()
            } label: {
                Image(systemName: "plus")
            }

            if !vm.reminders.isEmpty {
                EditButton()
            }
        }
    }
}

