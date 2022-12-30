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
    
    private let getFromCloudSubject: PassthroughSubject<Void, Never> = .init()
    let setToCloudSubject: PassthroughSubject<Void, Never> = .init()

    private var cancellables = Set<AnyCancellable>()
    private var getSubjectCancellable: AnyCancellable? = nil
    private var setSubjectCancellable: AnyCancellable? = nil

    @Published var dayModels: [DayModel]
    
    @Published var isSyncing: Bool = false
    @Published var syncError: LocalizedAlertError? = nil
    
    private init() {
        
        if let encodedHolder = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "DayModelHolder"),
           let holder = try? JSONDecoder().decode(DayModelHolder.self, from: encodedHolder) {
            
            self.dayModels = holder.models
        } else {
            self.dayModels = []
        }
                        
        getFromCloud()
        
        getSubjectCancellable = getFromCloudSubject
            .debounce(for: .seconds(DevPrefs.syncFromAfterChangeReceiving), scheduler: RunLoop.main)
            .sink { _ in
                print("get sink")
                self.getFromCloud()
            }
        
        setSubjectCancellable = setToCloudSubject
            .debounce(for: .seconds(DevPrefs.syncToCloudAfterChangeDebounce), scheduler: RunLoop.main)
            .sink { _ in
                print("set sink")
                self.setToCloud(self.dayModels)
            }

                
        let sharedPublisher = $dayModels.share()
        
        sharedPublisher
            .dropFirst()
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
        
                
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendSubject), name: .init("performCloudSyncing"), object: nil)

    }
    
    @objc private func sendSubject() {
        getFromCloudSubject.send()
    }
        
    private func getFromCloud() {
        Task {
            await MainActor.run {
                self.isSyncing = true
            }
            switch await cloudManager.syncDayModelsFromCloud() {
            case .success(let cloudDayModels):
                
                await MainActor.run {
                    self.syncError = nil
                    self.isSyncing = false
                }
                                                
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
                
                
            case .failure(_):
                await MainActor.run {
                    self.syncError = LocalizedAlertError(error: CustomError.getFromCloud)
                    self.isSyncing = false
                }
            }
        }
    }

    private func setToCloud(_ value: [DayModel]) {
        Task {
            await MainActor.run {
                self.isSyncing = true
            }
            switch await CloudManager.instance.syncToCloud(value) {
            case .success(_):
                await MainActor.run {
                    self.syncError = nil
                    self.isSyncing = false
                }
            case .failure(_):
                await MainActor.run {
                    self.syncError = LocalizedAlertError(error: CustomError.setToCloud)
                    self.isSyncing = false
                }
            }
        }
    }
    
    private func syncToUserDefaults(_ value: [DayModel]) {
        guard let userDefaults = UserDefaults(suiteName: "group.plannerapp"),
              let encodedHolder = try? JSONEncoder().encode(DayModelHolder(models: value)) else { return }
        
        userDefaults.set(encodedHolder, forKey: "DayModelHolder")
    }
        
    static func syncFromUserDefaults() -> [DayModel] {
        let encodedHolder = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "DayModelHolder") ?? .init()
        
        let holder = try? JSONDecoder().decode(DayModelHolder.self, from: encodedHolder)

        return holder?.models ?? []
    }
    
}
