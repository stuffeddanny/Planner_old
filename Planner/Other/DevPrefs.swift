//
//  DevPrefs.swift
//  Planner
//
//  Created by Danny on 11/26/22.
//

import SwiftUI

struct DevPrefs {
    static let daySelectingAnimationDuration: Double = 0.25
    static let daySelectingAnimation: Animation = .easeInOut(duration: daySelectingAnimationDuration)
    
    static let weekHighlightingAnimationDuration: Double = 0.3
    static let weekHighlightingAnimation: Animation = .easeInOut(duration: weekHighlightingAnimationDuration)
    
    static let monthSlidingAnimationDuration: Double = 0.4
    static let monthSlidingAnimation: Animation = .easeInOut(duration: monthSlidingAnimationDuration)
    
    static let monthAppearingAfterSlidingAnimationDuration: Double = 0.3
    static let monthAppearingAfterSlidingAnimation: Animation = .easeInOut(duration: monthAppearingAfterSlidingAnimationDuration)
}
