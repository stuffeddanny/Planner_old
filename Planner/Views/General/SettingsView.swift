//
//  SettingsView.swift
//  Planner
//
//  Created by Danny on 11/28/22.
//

import SwiftUI
import Combine

struct SettingsView: View {
    
    @FocusState private var focusedTag: Tag?
        
    @StateObject private var vm = SettingsViewModel()
            
    @State private var showApplyConfDialog: Bool = false
    @State private var showResetConfDialog: Bool = false
    
    @Environment(\.presentationMode) private var presentationMode

    init() {}
            
    var body: some View {
        List {
            
            Section {
                Toggle("Sync reminders through iCloud", isOn: vm.isSyncAvailable ? $vm.syncThroughICloudEnabledToggle : .constant(false))
                    .disabled(!vm.isSyncAvailable)
            } footer: {
                if !vm.isSyncAvailable {
                    Text("You must be signed in your Apple ID account to use iCloud")
                }
            }
            
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
            
            Section(header: Text("Tags (\(vm.tags.count))")) {
                if !vm.tags.isEmpty {
                    ForEach(vm.tags) { tag in
                        if let index = vm.tags.firstIndex(of: tag) {
                            ColorPicker(selection: $vm.tags[index].color, supportsOpacity: false) {
                                TextField("Name", text: $vm.tags[index].text)
                                    .focused($focusedTag, equals: tag)
                                    .submitLabel(.done)
                            }
                            .onChange(of: focusedTag) { newValue in
                                if newValue != tag && tag.text.isEmpty {
                                    vm.tags[index].text = "New tag"
                                }
                            }
                             .swipeActions(allowsFullSwipe: true) {
                                if vm.tags.count > 1 {
                                    Button("Delete", role: .destructive) {
                                        vm.tags.remove(at: index)
                                    }
                                }
                            }
                        }
                    }
                    
                } else {
                    Text("You have no tags created")
                        .foregroundColor(.secondary)
                }
                
                Button("Add tag") {
                    withAnimation {
                        let newTag = Tag(text: "", color: .accentColor)
                        vm.tags.append(newTag)
                        focusedTag = newTag
                    }
                }
                .disabled(vm.tags.count >= DevPrefs.tagsAmountLimit)
            }
            
            Section(footer: Text("Color of weekends columns")) {
                ColorPicker("Weekends color", selection: $vm.weekendsColorPicker, supportsOpacity: false)
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
                    UIApplication.shared.endEditing()
                    showApplyConfDialog = true
                }
                .disabled(vm.applyButtonIsDisabled)
            }
            
            Section {
                Button("Reset") {
                    showResetConfDialog = true
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .onReceive(vm.$tags.removeDuplicates()) { newValue in
            let filtered = newValue.filter({ $0.text.count > DevPrefs.tagNameLimit })
            for tagWithBrokenLimit in filtered {
                if let index = vm.tags.firstIndex(of: tagWithBrokenLimit) {
                    vm.tags[index].text = String(tagWithBrokenLimit.text.prefix(DevPrefs.tagNameLimit))
                }
            }
        }
        .confirmationDialog("Are you sure you want to apply changes?", isPresented: $showApplyConfDialog, titleVisibility: .visible, actions: getApplyConfDialog)
        .confirmationDialog("Warning! All settings will be reset to default values.", isPresented: $showResetConfDialog, titleVisibility: .visible, actions: getResetConfDialog)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onOpenURL { url in
            guard
                url.scheme == "planner",
                url.host == "reminder"
            else {
                return
            }
            
            presentationMode.wrappedValue.dismiss()

        }

    }
            
    @ViewBuilder
    private func getApplyConfDialog() -> some View {
        Button("Apply") {
            vm.apply()
        }
        Button("Cancel", role: .cancel) {}
    }
    
    @ViewBuilder
    private func getResetConfDialog() -> some View {
        Button("Reset to defaults") {
            vm.resetToDefault()
        }
        Button("Cancel", role: .cancel) {}
    }
}







struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
