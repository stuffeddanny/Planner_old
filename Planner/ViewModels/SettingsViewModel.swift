//
//  SettingsViewModel.swift
//  Planner
//
//  Created by Danny on 11/28/22.
//

import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()
    @Published var applyButtonIsDisabled: Bool = true
    @Published var isSyncAvailable: Bool = false
    
    private let manager: SettingManager = SettingManager.instance
    
    // Pickers
    @Published var accentColorPicker: Color
    @Published var selectedDayColorPicker: Color
    @Published var todaysDayColorPicker: Color
    @Published var weekendsColorPicker: Color
    @Published var backgroundColorPicker: Color
    
    // Toggles
    @Published var isTodayInvertedToggle: Bool
    @Published var isSelectedDayInvertedToggle: Bool
    @Published var syncThroughICloudEnabledToggle: Bool

    // Sliders
    @Published var gapsBetweenDays: Int
    
    // Tags
    @Published var tags: [Tag]
    
    init() {
        
        accentColorPicker = manager.settings.accentColor
        selectedDayColorPicker = manager.settings.selectedDayColor
        todaysDayColorPicker = manager.settings.todaysDayColor
        weekendsColorPicker = manager.settings.weekendsColor
        backgroundColorPicker = manager.settings.backgroundColor
        
        isTodayInvertedToggle = manager.settings.isTodayInverted
        isSelectedDayInvertedToggle = manager.settings.isSelectedDayInverted
        syncThroughICloudEnabledToggle = manager.settings.syncThroughICloudEnabled
        
        gapsBetweenDays = manager.settings.gapBetweenDays
        
        tags = manager.settings.tags
        
        Task {
            await checkICloudStatus()
        }
        
        addSubs()
    }
    
    private func checkICloudStatus() async {
        switch await CloudManager.instance.getICloudStatus() {
        case .success(let status):
            switch status {
            case .available:
                await MainActor.run {
                    isSyncAvailable = true
                }
            default:
                break
            }
        case .failure(_):
            break
        }
    }
    
    private func getAllFieldsFromSettings() {
        accentColorPicker = manager.settings.accentColor
        selectedDayColorPicker = manager.settings.selectedDayColor
        todaysDayColorPicker = manager.settings.todaysDayColor
        weekendsColorPicker = manager.settings.weekendsColor
        backgroundColorPicker = manager.settings.backgroundColor
        
        isTodayInvertedToggle = manager.settings.isTodayInverted
        isSelectedDayInvertedToggle = manager.settings.isSelectedDayInverted
        
        gapsBetweenDays = manager.settings.gapBetweenDays
        
        tags = manager.settings.tags

    }
    
    private func addSubs() {
       
        $accentColorPicker
            .combineLatest($selectedDayColorPicker, $weekendsColorPicker, $backgroundColorPicker)
            .sink { accent, selectedColor, weekendsColor, background in
                self.applyButtonIsDisabled = !(
                    accent != self.manager.settings.accentColor ||
                    selectedColor != self.manager.settings.selectedDayColor ||
                    weekendsColor != self.manager.settings.weekendsColor ||
                    background != self.manager.settings.backgroundColor
                )
            }
            .store(in: &cancellables)
        
        $todaysDayColorPicker
            .combineLatest($isTodayInvertedToggle, $isSelectedDayInvertedToggle, $gapsBetweenDays)
            .sink { todaysColor, isTodayInverted, isSelectedInverted, gaps in
                self.applyButtonIsDisabled = !(
                    todaysColor != self.manager.settings.todaysDayColor ||
                    isTodayInverted != self.manager.settings.isTodayInverted ||
                    isSelectedInverted != self.manager.settings.isSelectedDayInverted ||
                    gaps != self.manager.settings.gapBetweenDays
                )
            }
            .store(in: &cancellables)
        
        $tags
//            .combineLatest()
            .sink { tags in
                self.applyButtonIsDisabled = !(
                    tags != self.manager.settings.tags
                )
            }
            .store(in: &cancellables)
        
    }
    
    func resetToDefault() {
        manager.settings = UserSettingsModel(modifiedDate: .now)
        getAllFieldsFromSettings()
        
    }
    
    func apply() {
        manager.settings = UserSettingsModel(
            accentColor: accentColorPicker,
            selectedDayColor: selectedDayColorPicker,
            weekendsColor: weekendsColorPicker,
            backgroundColor: backgroundColorPicker,
            todaysDayColor: todaysDayColorPicker,
            isTodayInverted: isTodayInvertedToggle,
            isSelectedDayInverted: isSelectedDayInvertedToggle,
            syncThroughICloudEnabled: syncThroughICloudEnabledToggle,
            gapBetweenDays: gapsBetweenDays,
            tags: tags,
            modifiedDate: .now
        )
        
        applyButtonIsDisabled = true
    }
}
