//
//  SettingManager.swift
//  Planner
//
//  Created by Danny on 11/29/22.
//

import SwiftUI
import Combine
import WidgetKit

class SettingManager: ObservableObject {
    private let cloudManager = CloudManager.instance
    static let instance = SettingManager()
    private var cancellables = Set<AnyCancellable>()
        

    
    @Published var settings: UserSettingsModel {
        didSet {
            applySettings()
        }
    }
    
    @Published var isSyncing: Bool = false
    @Published var syncError: LocalizedAlertError? = nil

    
    private func checkForDeletedTags() {
        let tags = settings.tags
                        
        DayModelManager.instance.dayModels = DayModelManager.instance.dayModels.map { dayModel in
            var newDayModel = dayModel
            newDayModel.reminders = dayModel.reminders.map { reminder in
                
                if let tagId = reminder.tagId, !tags.map({$0.id}).contains(tagId) {
                    var newReminder = reminder
                    newReminder.tagId = nil
                    return newReminder
                }
                
                return reminder
                
            }
            return newDayModel
        }

    }
    
    func retrySyncing() {
        saveSettings()
    }
    
    private func saveSettings(_ value: UserSettingsModel? = nil) {
        guard let userDefaults = UserDefaults(suiteName: "group.plannerapp"),
            let encodedSettings = try? JSONEncoder().encode(value) else { return }
        
        userDefaults.set(encodedSettings, forKey: "userSettings")
        
        Task {
            
            await MainActor.run {
                self.isSyncing = true
            }
            
            switch await cloudManager.syncToCloud(value ?? settings) {
            case .success(_):
                
                await MainActor.run {
                    self.syncError = nil
                    self.isSyncing = false
                }
                
            case .failure(_):
                await MainActor.run {
                    self.syncError = LocalizedAlertError(error: CustomError.setSettingsToCloud)
                    self.isSyncing = false
                }
            }
        }
        
    }
    
    private func applySettings() {
        // Reloads Widgets
        WidgetCenter.shared.reloadAllTimelines()

        // Updating
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(settings.accentColor)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(settings.accentColor)]
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(settings.accentColor)
    }
    
    static func getFromUserDefaults() -> UserSettingsModel {
        let encodedSettings = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "userSettings")
        let settings = try? JSONDecoder().decode(UserSettingsModel.self, from: encodedSettings ?? Data())
        return settings ?? UserSettingsModel()
    }
    
    private init() {
        
        if let encodedSettings = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "userSettings"),
           let settings = try? JSONDecoder().decode(UserSettingsModel.self, from: encodedSettings) {
            self.settings = settings
        } else {
            self.settings = UserSettingsModel()
        }
        
        Task {
            switch await cloudManager.syncSettingsFromCloud() {
            case .success(let settings):
                if let ownModifiedDate = self.settings.modifiedDate,
                   let cloudModifiedDate = settings.modifiedDate,
                   cloudModifiedDate <= ownModifiedDate {
                    saveSettings(settings)
                    
                    break
                }
                
                await MainActor.run {
                    self.settings = settings
                }
                
            case .failure(_):
                #warning("Save")
            }
            
        }
        
        $settings
            .sink { newValue in
                if newValue.tags != self.settings.tags {
                    self.checkForDeletedTags()
                }
                
                if self.settings != newValue {
                    self.saveSettings(newValue)
                }

            }
            .store(in: &cancellables)
    }
}
