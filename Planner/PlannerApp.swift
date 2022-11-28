//
//  PlannerApp.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI


class SettingManager: ObservableObject {
    
    @Published var settings: UserSettings {
        didSet {
            guard let data = try? JSONEncoder().encode(settings) else { return }
            UserDefaults.standard.set(data, forKey: "userSettings")
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(settings.accentColor)]
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(settings.accentColor)]
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(settings.accentColor)

        }
    }
    
    init() {
        
        let data = UserDefaults.standard.data(forKey: "userSettings") ?? .init()
        
        let decoded = try? JSONDecoder().decode(UserSettings.self, from: data)
        
        settings = decoded ?? UserSettings()

        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(settings.accentColor)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(settings.accentColor)]
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(settings.accentColor)

    }
}

@main
struct PlannerApp: App {
    
    @State private var showLaunchView: Bool = true
    @StateObject private var settingManager = SettingManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainScreenView()
                
                if showLaunchView {
                    LaunchView(showLaunchView: $showLaunchView)
                        .transition(.asymmetric(insertion: .identity, removal: .move(edge: .leading)))
                        .zIndex(2.0)
                }
            }
            .environmentObject(settingManager)
        }
    }
}
