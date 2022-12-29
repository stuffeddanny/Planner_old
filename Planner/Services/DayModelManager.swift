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
    
    private var cancellables = Set<AnyCancellable>()
    
    #warning("Sync with iCloud with debounce using publisher + refresh reminderList + no need sync button in settings")
    @Published var dayModels: [DayModel]
    
    private init() {
        
        if let encodedHolder = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "DayModelHolder"),
           let holder = try? JSONDecoder().decode(DayModelHolder.self, from: encodedHolder) {
            
            self.dayModels = holder.models
        } else {
            self.dayModels = []
        }
                
        getFromCloud()
                
        let sharedPublisher = $dayModels.share().dropFirst()
        
        sharedPublisher
            .removeDuplicates()
            .sink { newValue in
                print("user sink")
                self.syncToUserDefaults(newValue)
            }
            .store(in: &cancellables)
                
        sharedPublisher
            .debounce(for: .seconds(DevPrefs.widgetReloadDebounce), scheduler: RunLoop.main)
            .sink { _ in
                print("widget sink")
                WidgetCenter.shared.reloadAllTimelines()
            }
            .store(in: &cancellables)

        sharedPublisher
            .debounce(for: .seconds(DevPrefs.syncToCloudAfterChangeDebounce), scheduler: RunLoop.main)
            .sink { newValue in
                print("set sink")
                self.setToCloud(newValue)
            }
            .store(in: &cancellables)

    }
    
    
    private func getFromCloud() {
        Task {
            switch await cloudManager.syncDayModelsFromCloud() {
            case .success(let cloudDayModels):
                
                print("Got data from cloud \(cloudDayModels)")
                                                
                dayModels = cloudDayModels.map({ cloudDayModel in
                    if let userDayModel = dayModels.first(where: { $0.id == cloudDayModel.id }) {
                        if cloudDayModel.dateModified > userDayModel.dateModified {
                            
                            let icloudReminders = cloudDayModel.reminders.compactMap { cloudReminder in
                                if cloudReminder.dateModified > userDayModel.dateModified {
                                    return cloudReminder
                                } else {
                                    return nil
                                }
                            }
                            
                            var userReminders = userDayModel.reminders
                            
                            icloudReminders.forEach { reminder in
                                if let index = userReminders.firstIndex(where: {$0.id == reminder.id}) {
                                    userReminders[index] = reminder
                                } else {
                                    userReminders.append(reminder)
                                }
                            }
                            
                            var newUserDayModel = userDayModel
                            
                            newUserDayModel.reminders = userReminders
                            
                            if let lastDate = userReminders.map({$0.dateModified}).sorted(by: {$0 > $1}).first {
                                newUserDayModel.dateModified = lastDate
                            }
                            
                            return newUserDayModel
                            
                        } else {
                            // Update cloud
                            return userDayModel
                        }
                    } else {
                        
                        return cloudDayModel
                    }
                })
                
                
            case .failure(let error):
                print("Error fetching dayModels from cloud \(error.localizedDescription)")
            }
        }
    }

    private func setToCloud(_ value: [DayModel]) {
        Task {
            switch await cloudManager.syncToCloud(value) {
            case .success(_):
                print("successfully saved to cloud")
            case .failure(let error):
                print("error syncing to cloud \(error.localizedDescription)")
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
