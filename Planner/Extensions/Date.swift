//
//  Date.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import Foundation

extension Date {
    
    static func compareDates(date1: Date, date2: Date) -> Bool {
        if Calendar.gregorianWithSunAsFirstWeekday.compare(date1, to: date2, toGranularity: .minute).rawValue == 1 {
            return true
        }
        
        return false
    }
    
    func isToday() -> Bool {
        Calendar.gregorianWithSunAsFirstWeekday.isDate(self, inSameDayAs: .now)
    }
    
    func weekdaySymbol() -> String {
        let weekday = Calendar.gregorianWithSunAsFirstWeekday.component(.weekday, from: self)
        return Calendar.gregorianWithSunAsFirstWeekday.shortWeekdaySymbols[weekday-1]
    }

    func formattedToTimeFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        return formatter.string(from: self)
    }

    func getDayModelsForMonth() -> [DayViewModel] {
        let calendar = Calendar.gregorianWithSunAsFirstWeekday

        var result: [DayViewModel] = []

        let startOfCurrentMonth = self.startOfMonth
        let startOfPrevMonth = self.monthAgo().startOfMonth

        let firstWeekDay = calendar.component(.weekday, from: startOfCurrentMonth)

        if firstWeekDay > 1 {
            let lastDayOfPrevMonth = startOfPrevMonth.endOfMonth.startOfDay
            
            for index in -(firstWeekDay-2)...0 {
                result.append(DayViewModel(id: calendar.date(byAdding: .day, value: index, to: lastDayOfPrevMonth)!, secondary: true))
            }
        }

        for day in calendar.range(of: .day, in: .month, for: startOfCurrentMonth)! {
            result.append(DayViewModel(id: calendar.date(byAdding: .day, value: day - 1, to: startOfCurrentMonth)!))
        }
        
        let endOfCurrentMonth = self.endOfMonth
        let startOfFollowingMonth = self.monthFurther().startOfMonth
        
        let lastWeekDay = calendar.component(.weekday, from: endOfCurrentMonth)

        if lastWeekDay < 7 {
            let firstDayOfFollowingMonth = startOfFollowingMonth.startOfDay
            
            for index in 0...6-(lastWeekDay) {
                result.append(DayViewModel(id: calendar.date(byAdding: .day, value: index, to: firstDayOfFollowingMonth)!, secondary: true))
            }
        }
        
        return result
    }
    
    func getDayModelsForWeek() -> [DayViewModel] {
        let calendar = Calendar.gregorianWithSunAsFirstWeekday

        var result: [DayViewModel] = []
        
        

        if calendar.isDate(self, equalTo: self.startOfMonth, toGranularity: .weekOfYear) { // First week
            let firstWeekdayNum = calendar.component(.weekday, from: self.startOfMonth)
            
            if firstWeekdayNum > 1 {
                let lastDayOfPrevMonth = self.monthAgo().endOfMonth.startOfDay
                
                for index in -(firstWeekdayNum-2)...0 {
                    result.append(DayViewModel(id: calendar.date(byAdding: .day, value: index, to: lastDayOfPrevMonth)!, secondary: true))
                }
            }
            for index in 0...7-firstWeekdayNum {
                result.append(DayViewModel(id: calendar.date(byAdding: .day, value: index, to: self.startOfMonth)!, secondary: false))
            }
        } else if calendar.isDate(self, equalTo: self.endOfMonth, toGranularity: .weekOfYear) { // Last week
            let lastWeekdayNum = calendar.component(.weekday, from: self.endOfMonth)
            
            for index in -(lastWeekdayNum-1)...0 {
                result.append(DayViewModel(id: calendar.date(byAdding: .day, value: index, to: self.endOfMonth.startOfDay)!, secondary: false))
            }

            
            if lastWeekdayNum < 7 {
                let firstDayOfFollowingMonth = self.monthFurther().startOfMonth
                
                for index in 0...6-lastWeekdayNum {
                    result.append(DayViewModel(id: calendar.date(byAdding: .day, value: index, to: firstDayOfFollowingMonth)!, secondary: true))
                }
            }
        } else { // In the middle
            for day in 0...6 {
                result.append(DayViewModel(id: calendar.date(byAdding: .day, value: day, to: self.startOfWeekInYear)!))
            }
        }
        
        return result
    }
    
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self)
    }
    
    var startOfDay: Date {
        return Calendar.gregorianWithSunAsFirstWeekday.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        let components = Calendar.gregorianWithSunAsFirstWeekday.dateComponents([.year, .month], from: self)
        
        return Calendar.gregorianWithSunAsFirstWeekday.date(from: components)!
    }
    
    var startOfWeekInYear: Date {
        let components = Calendar.gregorianWithSunAsFirstWeekday.dateComponents([.year, .yearForWeekOfYear, .weekOfYear], from: self)
        
        return Calendar.gregorianWithSunAsFirstWeekday.date(from: components)!
    }
        
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.gregorianWithSunAsFirstWeekday.date(byAdding: components, to: startOfDay)!
    }
    
    var endOfWeekInYear: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.gregorianWithSunAsFirstWeekday.date(byAdding: components, to: startOfWeekInYear)!
    }
        
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.gregorianWithSunAsFirstWeekday.date(byAdding: components, to: startOfMonth)!
    }
    
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self)
    }
    
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
    
    func monthAgo() -> Date {
        Calendar.gregorianWithSunAsFirstWeekday.date(byAdding: .month, value: -1, to: self)!
    }
    
    func monthFurther() -> Date {
        Calendar.gregorianWithSunAsFirstWeekday.date(byAdding: .month, value: 1, to: self)!
    }
    
    func weekAgo() -> Date {
        if Calendar.gregorianWithSunAsFirstWeekday.isDate(self, equalTo: self.startOfMonth, toGranularity: .weekOfYear) {
            if Calendar.gregorianWithSunAsFirstWeekday.component(.weekday, from: self.startOfMonth) > 1 { // First week
                return self.startOfWeekInYear
            } else {
                return self.monthAgo().endOfMonth.startOfWeekInYear
            }
        }
        if !Calendar.gregorianWithSunAsFirstWeekday.isDate(Calendar.gregorianWithSunAsFirstWeekday.date(byAdding: .weekOfMonth, value: -1, to: self)!, equalTo: self.startOfMonth, toGranularity: .month) {
            return self.startOfMonth
        }
        return Calendar.gregorianWithSunAsFirstWeekday.date(byAdding: .weekOfMonth, value: -1, to: self)!.startOfWeekInYear
    }
    
    func weekFurther() -> Date {
        if Calendar.gregorianWithSunAsFirstWeekday.isDate(self, equalTo: self.endOfMonth, toGranularity: .weekOfYear) {
            if Calendar.gregorianWithSunAsFirstWeekday.component(.weekday, from: self.endOfMonth) < 7 { // Last week
                return self.endOfWeekInYear
            } else {
                return self.monthFurther().startOfMonth
            }
        }
        if !Calendar.gregorianWithSunAsFirstWeekday.isDate(Calendar.gregorianWithSunAsFirstWeekday.date(byAdding: .weekOfYear, value: 1, to: self)!, equalTo: self.endOfMonth, toGranularity: .month) {
            return self.endOfMonth.startOfDay
        }
        return Calendar.gregorianWithSunAsFirstWeekday.date(byAdding: .weekOfMonth, value: 1, to: self)!.startOfWeekInYear
    }
    
    static func isSameWeek(_ date1: Date, _ date2: Date) -> Bool {
        if Calendar.gregorianWithSunAsFirstWeekday.isDate(date1, equalTo: date2, toGranularity: .month) {
           return Calendar.gregorianWithSunAsFirstWeekday.isDate(date1, equalTo: date2, toGranularity: .weekOfYear)
        }
        return false
    }
}
