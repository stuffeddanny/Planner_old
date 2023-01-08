//
//  NotificationManager.swift
//  Planner
//
//  Created by Danny on 12/7/22.
//

import UserNotifications

class NotificationManager {
    
    static let instance = NotificationManager()
    
    private init() {}
    
    func requestAuthorization(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        
        let options: UNAuthorizationOptions = [.alert]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(success))
            }
        }
    }
    
    func removeAllDeliveredNotificationsFromNotificationCenter() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func removeDeliveredNotificationsFromNotificationCenter(with ids: [UUID]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids.map({ $0.uuidString }))
    }
    
    func removePendingNotification(with ids: [UUID]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids.map({ $0.uuidString }))
    }
    
    func scheduleNotification(with content: UNMutableNotificationContent, identifier: UUID, dateComponents: DateComponents) {
                
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: trigger)
        
        
        UNUserNotificationCenter.current().add(request)
    }
}
