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
        
    var dayModels: [DayModel] {
        get {
            syncFromUserDefaults()
        }
        set {
            syncToUserDefaults(newValue)
        }
    }

    
    private init() {}
    
    func syncToUserDefaults(_ value: [DayModel]) {
        guard let userDefaults = UserDefaults(suiteName: "group.plannerapp"),
              let encodedHolder = try? JSONEncoder().encode(DayModelHolder(models: value)) else { return }
        
        userDefaults.set(encodedHolder, forKey: "DayModelHolder")
    }
    
    func syncFromUserDefaults() -> [DayModel] {
        let encodedHolder = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "DayModelHolder") ?? .init()
        
        let holder = try? JSONDecoder().decode(DayModelHolder.self, from: encodedHolder)

        return holder?.models ?? []
    }
    
}
