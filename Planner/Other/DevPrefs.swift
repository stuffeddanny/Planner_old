//
//  DevPrefs.swift
//  Planner
//
//  Created by Danny on 11/26/22.
//

import SwiftUI

struct DevPrefs {
    static let maximumGapBetweenDays: Int = 200
    
    static let tagNameLimit: Int = 15
    static let tagsAmountLimit: Int = 6
    
    static let daySelectingAnimationDuration: Double = 0.1
    static let daySelectingAnimation: Animation = .easeInOut(duration: daySelectingAnimationDuration)
    
    static let weekHighlightingAnimationDuration: Double = 0.2
    static let weekHighlightingAnimation: Animation = .easeInOut(duration: weekHighlightingAnimationDuration)
    
    static let noteAppearingAnimationDuration: Double = 0.1
    static let noteAppearingAnimation: Animation = .easeInOut(duration: noteAppearingAnimationDuration)

    static let monthSlidingAnimationDuration: Double = 0.3
    static let monthSlidingAnimation: Animation = .linear(duration: monthSlidingAnimationDuration)
    
    static let monthAppearingAfterSlidingAnimationDuration: Double = 0.2
    static let monthAppearingAfterSlidingAnimation: Animation = .easeInOut(duration: monthAppearingAfterSlidingAnimationDuration)
    
    static let slidingAfterFingerAnimation: Animation = .linear(duration: 0.3)
    
    // value ~ 1 -> no difference between finger translation width and calendar offset width
    // value ~ 0 -> almost zero moving after finger
    static let slidingAfterFingerFactor: Double = 0.8
    static let slidingToStartPositionAnimation: Animation = .easeOut(duration: 0.2)
    
    // value ~ 1 -> to swipe user's gesture translation width needs to be equal to the screen width
    // value ~ 0 -> to swipe user's gesture translation width needs to be > 0
    static let screenWidthFactor: Double = 0.7
    
    static let syncDebounce: Int = 5
}
