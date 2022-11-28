//
//  SettingsView.swift
//  Planner
//
//  Created by Danny on 11/28/22.
//

import SwiftUI

/// <#Description#>
struct SettingsView: View {
        
    @StateObject private var vm: SettingsViewModel
    
    @State private var showConfDialog: Bool = false
    
    init(_ manager: SettingManager) {
        _vm = .init(wrappedValue: SettingsViewModel(manager))
    }
    
    var body: some View {
        List {
            Section(footer: Text("Accent color of whole app")) {
                ColorPicker("Accent color", selection: $vm.accentColorPicker, supportsOpacity: false)
            }
            Section(footer: Text("Color of selected day and todays day highlight")) {
                ColorPicker("Selected day highlight color", selection: $vm.selectedDayColorPicker, supportsOpacity: false)
                ColorPicker("Today highlight color", selection: $vm.todaysDayColorPicker, supportsOpacity: false)
            }
            Section(footer: Text("Color of weekends columns")) {
                ColorPicker("Weekends color", selection: $vm.weekendsColorPicker, supportsOpacity: true)
            }
            Section(footer: Text("Color of calendar background. Clear by default")) {
                ColorPicker("Background color", selection: $vm.backgroundColorPicker, supportsOpacity: true)
            }
            Section(footer: Text("Inverts color of number of selected or todays day")) {
                Toggle("Invert selected day", isOn: $vm.isSelectedDayInvertedToggle)
                Toggle("Invert todays day", isOn: $vm.isTodayInvertedToggle)
            }
            
            

            Section {
                Button("Apply changes") {
                    showConfDialog = true
                }
                .disabled(vm.applyButtonIsDisabled)
            }
        }
        .confirmationDialog("Are you sure you want to apply changes?", isPresented: $showConfDialog, titleVisibility: .visible) {
            Button("Apply") {
                vm.apply()
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}







struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(SettingManager())
        }
    }
}
