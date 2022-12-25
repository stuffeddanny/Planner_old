//
//  HapticManager.swift
//  Planner
//
//  Created by Danny on 12/1/22.
//

import SwiftUI

final class HapticManager {
    
    static let instance = HapticManager()
    
    private init() {}
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    func notification(of type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
