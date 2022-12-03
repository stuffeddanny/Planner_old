//
//  SettingManager.swift
//  Planner
//
//  Created by Danny on 11/29/22.
//

import SwiftUI
import Combine

class SettingManager: ObservableObject {
    
    @Published var settings: UserSettings
    
    private var cancellables = Set<AnyCancellable>()
    
    private func saveSettings(_ settings: UserSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: "userSettings")

        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(settings.accentColor)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(settings.accentColor)]
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(settings.accentColor)

    }
    
    init() {
                
        let data = UserDefaults.standard.data(forKey: "userSettings") ?? .init()
        
        let decoded = try? JSONDecoder().decode(UserSettings.self, from: data)
        
        settings = decoded ?? UserSettings()
        
        saveSettings(settings)
        
        $settings
            .sink { newValue in
                self.saveSettings(newValue)
            }
            .store(in: &cancellables)

    }
}
