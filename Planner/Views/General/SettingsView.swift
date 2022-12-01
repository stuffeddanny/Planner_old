//
//  SettingsView.swift
//  Planner
//
//  Created by Danny on 11/28/22.
//

import SwiftUI

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
            Section(footer: Text("Color of calendar background. Clear by default")) {
                ColorPicker("Background color", selection: $vm.backgroundColorPicker, supportsOpacity: true)
            }
            
            Section(footer: Text("Color of selected day and todays day highlight")) {
                ColorPicker("Selected day highlight color", selection: $vm.selectedDayColorPicker, supportsOpacity: false)
                ColorPicker("Today highlight color", selection: $vm.todaysDayColorPicker, supportsOpacity: false)
            }
            Section(footer: Text("Color of weekends columns")) {
                ColorPicker("Weekends color", selection: $vm.weekendsColorPicker, supportsOpacity: true)
            }
            Section(footer: Text("Inverts color of number of selected or todays day")) {
                Toggle("Invert selected day", isOn: $vm.isSelectedDayInvertedToggle)
                Toggle("Invert todays day", isOn: $vm.isTodayInvertedToggle)
            }
            
            Section(footer: Text("Vertical gaps between days in calendar")) {
                HStack {
                    Slider(value: Binding<Double>(get: {
                        return Double(vm.gapsBetweenDays)
                    }, set: {
                        vm.gapsBetweenDays = Int($0)
                    }), in: 0...Double(DevPrefs.maximumGapBetweenDays), step: (Double(DevPrefs.maximumGapBetweenDays)/100.0) * 5)

                    Text("\(vm.gapsBetweenDays / (DevPrefs.maximumGapBetweenDays/100))%")
                        .frame(minWidth: 40)
                }
            }
            

            Section {
                Button("Apply changes") {
                    showConfDialog = true
                }
                .disabled(vm.applyButtonIsDisabled)
            }
        }
        .confirmationDialog("Are you sure you want to apply changes?", isPresented: $showConfDialog, titleVisibility: .visible, actions: getConfDialog)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func getConfDialog() -> some View {
        Button("Apply") {
            vm.apply()
        }
        Button("Cancel", role: .cancel) {}
    }
}







struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(SettingManager())
        }
    }
}
