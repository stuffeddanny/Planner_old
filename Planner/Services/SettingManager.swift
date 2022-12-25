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
    
    @Published var settings: UserSettingsModel {
        didSet {
            
            if settings.tags != oldValue.tags {
                checkForDeletedTags()
            }
            
            saveSettings()
        }
    }
    
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
    
    private let cloudManager = CloudManager.instance
    
    static let instance = SettingManager()
        
    private func saveSettings() {
        guard let userDefaults = UserDefaults(suiteName: "group.plannerapp"),
            let encodedSettings = try? JSONEncoder().encode(settings) else { return }
        
        userDefaults.set(encodedSettings, forKey: "userSettings")
        
        Task {
            switch await cloudManager.syncToCloud(settings) {
            case .success(let record):
                print("Settings were successfully saved \(record)")
            case .failure(let error):
                print("Error while saving settings to cloud \(error.localizedDescription)")
            }
        }
        
        applySettings()
    }
    
    private func applySettings() {
        // Reloads Widgets
        WidgetCenter.shared.reloadAllTimelines()

        // Updating
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(settings.accentColor)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(settings.accentColor)]
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(settings.accentColor)
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
                if !(settings.modifiedDate < self.settings.modifiedDate) {
                    await MainActor.run {
                        self.settings = settings
                    }
                }

            case .failure(let error):
                print("Error while getting settings from cloud \(error.localizedDescription)")
            }
            
        }
    }
}
