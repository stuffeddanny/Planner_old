//
//  MainScreenViewModel.swift
//  Planner
//
//  Created by Danny on 11/26/22.
//

import SwiftUI
import Combine

final class MainScreenViewModel: ObservableObject {
    
    @Published var firstDayOfMonthOnTheScreenDate: Date
    @Published var offset = CGSize()
    @Published var opacity: Double = 1
    @Published var monthName: String
    @Published var yearName: String

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let date = Date().startOfMonth
        firstDayOfMonthOnTheScreenDate = date
        monthName = date.month
        yearName = date.year
        addSubs()
    }
    
    private func addSubs() {
        $firstDayOfMonthOnTheScreenDate
            .sink { newValue in
                    self.monthName = newValue.month
                    self.yearName = newValue.year
            }
            .store(in: &cancellables)
    }
    
    func goTo(_ date: Date) {
        if !Calendar.current.isDate(firstDayOfMonthOnTheScreenDate, equalTo: date, toGranularity: .month) {
            if date < firstDayOfMonthOnTheScreenDate {
                withAnimation(DevPrefs.monthSlidingAnimation) {
                    offset = CGSize(width: UIScreen.main.bounds.size.width, height: 0)
                }
            } else {
                withAnimation(DevPrefs.monthSlidingAnimation) {
                    offset = CGSize(width: -UIScreen.main.bounds.size.width, height: 0)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (DevPrefs.monthSlidingAnimationDuration)) {
                self.firstDayOfMonthOnTheScreenDate = date.startOfMonth
                print("Month on the screen \(self.firstDayOfMonthOnTheScreenDate)")
                self.opacity = 0
                self.offset = CGSize()
                withAnimation(DevPrefs.monthAppearingAfterSlidingAnimation) {
                    self.opacity = 1
                }
            }
        }
    }
}
