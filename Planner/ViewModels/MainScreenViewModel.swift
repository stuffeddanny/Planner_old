//
//  MainScreenViewModel.swift
//  Planner
//
//  Created by Danny on 11/26/22.
//

import SwiftUI

final class MainScreenViewModel: ObservableObject {
    
    @Published var dateOnTheScreen: Date
    @Published var offset = CGSize()
    @Published var opacity: Double = 1

    init() {
        dateOnTheScreen = .now
    }
    
    func goTo(_ date: Date) {
        if !Calendar.current.isDate(dateOnTheScreen, equalTo: date, toGranularity: .month) {
            if date < dateOnTheScreen {
                withAnimation(DevPrefs.monthSlidingAnimation) {
                    offset = CGSize(width: UIScreen.main.bounds.size.width, height: 0)
                }
            } else {
                withAnimation(DevPrefs.monthSlidingAnimation) {
                    offset = CGSize(width: -UIScreen.main.bounds.size.width, height: 0)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (DevPrefs.monthSlidingAnimationDuration)) {
                self.dateOnTheScreen = date
                self.opacity = 0
                self.offset = CGSize()
                withAnimation(DevPrefs.monthAppearingAfterSlidingAnimation) {
                    self.opacity = 1
                }
            }
        }
    }
}
