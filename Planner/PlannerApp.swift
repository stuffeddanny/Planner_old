//
//  PlannerApp.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI
import CloudKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        
        if cloudKitNotification?.alertLocalizationKey == "changeInCloud" {
            NotificationCenter.default.post(name: .init("performCloudSyncing"), object: nil)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
        
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification)
        
        completionHandler(.init(rawValue: 0))
    }
    
}


@main
struct PlannerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var showLaunchView: Bool = true
        
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
        }
    }
}
