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
    
    init(reminders: Binding<[Reminder]>) {
        _vm = .init(wrappedValue: ReminderListViewModel(reminders))
    }
    
    var body: some View {
        NavigationView {
            Content
                .toolbar { getToolbar() }
                .navigationTitle("Reminders (\(vm.reminders.count))")
                .navigationBarTitleDisplayMode(.inline)
                .background(settingManager.settings.backgroundColor)
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
            .scrollDismissesKeyboard(.interactively)
            .listStyle(.plain)
        } else {
            Text("You have no reminders.\nTap '+' button to create one ")
                .lineSpacing(10)
                .multilineTextAlignment(.center)
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 30)
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

