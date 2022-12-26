//
//  DayModelManager.swift
//  Planner
//
//  Created by Danny on 12/23/22.
//

import CloudKit
import SwiftUI
import Combine
import WidgetKit

class DayModelManager {
    
    static let instance = DayModelManager()
    private let cloudManager = CloudManager.instance
    
    private let reloadWidgetsSubject = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable
    private var syncTask: Task<Void, Never>? = nil
            
    #warning("Sync with iCloud with debounce using publisher + refresh reminderList")
    var dayModels: [DayModel] {
        get {
            syncFromUserDefaults()
        }
        set {
            syncToUserDefaults(newValue)
            
            checkCloud()
            
            reloadWidgetsSubject.send()
        }
    }
    
    private init() {
        cancellable = reloadWidgetsSubject
            .debounce(for: .seconds(DevPrefs.widgetReloadDebounce), scheduler: RunLoop.main)
            .sink { _ in
                print("Widgets Reloading")
                WidgetCenter.shared.reloadAllTimelines()
            }
        
        checkCloud()

    }
    
    private func checkCloud() {
        syncTask?.cancel()
        
        syncTask = Task {
            switch await cloudManager.syncDayModelsFromCloud() {
            case .success(let cloudDayModels):
                guard let task = syncTask, !task.isCancelled else { return }
                
                print("Got data from cloud")
                                                
                self.dayModels = self.dayModels.map({ dayModel in // Going through day models in user defs
                        
                    if let dayModelFromCloud = cloudDayModels.first(where: { $0.id == dayModel.id }) { // If day model from user defs exists in cloud
                        
                        var newDayModel = dayModel
                        
                        
                        
                        newDayModel.reminders = dayModel.reminders.compactMap({ reminder in // going through reminders in user defs
                            
                            if let reminderFromCloud = dayModelFromCloud.reminders.first(where: {$0.id == reminder.id}) { // If reminder from user defs exists in cloud
                                
                                if reminderFromCloud.dateModified > reminder.dateModified { // Reminder in cloud is newer than in user default
                                    return reminderFromCloud
                                } else { // Reminder in cloud is outdated
                                    // Upload new version of reminder to cloud
                                    return reminder
                                }
                                
                            } else { // Reminder which exists in user defs doesnt exist in cloud
                                if dayModelFromCloud.dateModified > dayModel.dateModified { // If day model in cloud is newer
                                    return nil // we delete reminder from user defs since it doesnt exist in newer version of day model in cloud
                                } else { // If day model in user defs is newer than it is in cloud
                                    
                                    // Upload new version of reminder to cloud
                                    
                                    return reminder
                                }
                            }
                            
                        })
                        
                        return newDayModel
                        
                    }
                    
                    // upload day model to cloud
                    
                    return dayModel
                })
            case .failure(let error):
                print("Error fetching dayModels from cloud \(error.localizedDescription)")
            }
        }
    }
    
    private func syncToUserDefaults(_ value: [DayModel]) {
        guard let userDefaults = UserDefaults(suiteName: "group.plannerapp"),
              let encodedHolder = try? JSONEncoder().encode(DayModelHolder(models: value)) else { return }
        
        userDefaults.set(encodedHolder, forKey: "DayModelHolder")
    }
    
    private func syncFromUserDefaults() -> [DayModel] {
        let encodedHolder = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "DayModelHolder") ?? .init()
        
        let holder = try? JSONDecoder().decode(DayModelHolder.self, from: encodedHolder)

        return holder?.models ?? []
    }
    
}
