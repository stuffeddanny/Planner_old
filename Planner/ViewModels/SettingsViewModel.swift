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
    
    let manager: SettingManager
    
        
    // Pickers
    @Published var accentColorPicker: Color
    @Published var selectedDayColorPicker: Color
    @Published var todaysDayColorPicker: Color
    @Published var weekendsColorPicker: Color
    @Published var backgroundColorPicker: Color
    
    // Toggles
    @Published var isTodayInvertedToggle: Bool
    @Published var isSelectedDayInvertedToggle: Bool
    
    init(_ manager: SettingManager) {
        self.manager = manager
        
        accentColorPicker = manager.settings.accentColor
        selectedDayColorPicker = manager.settings.selectedDayColor
        todaysDayColorPicker = manager.settings.todaysDayColor
        weekendsColorPicker = manager.settings.weekendsColor
        backgroundColorPicker = manager.settings.backgroundColor
        
        isTodayInvertedToggle = manager.settings.isTodayInverted
        isSelectedDayInvertedToggle = manager.settings.isSelectedDayInverted
        
        addSubs()
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
            .combineLatest($isTodayInvertedToggle, $isSelectedDayInvertedToggle)
            .sink { todaysColor, isTodayInverted, isSelectedInverted in
                self.applyButtonIsDisabled = !(
                    todaysColor != self.manager.settings.todaysDayColor ||
                    isTodayInverted != self.manager.settings.isTodayInverted ||
                    isSelectedInverted != self.manager.settings.isSelectedDayInverted
                )
            }
            .store(in: &cancellables)
        
    }
    
    private func checkForApplyButton() {
        applyButtonIsDisabled = !(
            accentColorPicker != manager.settings.accentColor ||
            selectedDayColorPicker != manager.settings.selectedDayColor ||
            weekendsColorPicker != manager.settings.weekendsColor ||
            backgroundColorPicker != manager.settings.backgroundColor ||
            todaysDayColorPicker != manager.settings.todaysDayColor ||
            isTodayInvertedToggle != manager.settings.isTodayInverted ||
            isSelectedDayInvertedToggle != manager.settings.isSelectedDayInverted
        )
    }
    
    func apply() {
        var oldSettings = manager.settings
        
        oldSettings.accentColor = accentColorPicker
        oldSettings.selectedDayColor = selectedDayColorPicker
        oldSettings.todaysDayColor = todaysDayColorPicker
        oldSettings.weekendsColor = weekendsColorPicker
        oldSettings.backgroundColor = backgroundColorPicker
        oldSettings.isTodayInverted = isTodayInvertedToggle
        oldSettings.isSelectedDayInverted = isSelectedDayInvertedToggle
        
        manager.settings = oldSettings
        
        checkForApplyButton()
    }
}
