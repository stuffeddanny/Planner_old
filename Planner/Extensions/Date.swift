//
//  Date.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import Foundation

extension Date {
    
    func getDays() -> [DayModel] {
        var result: [DayModel] = []
        
        let dayDurationInSeconds: TimeInterval = 60*60*24
        
        let firstWeekDay = Calendar.current.component(.weekday, from: self.startOfMonth)
        
        var previousMonthDays: [Date] = []
        
        for day in stride(from: self.monthAgo()!.startOfMonth, to: self.monthAgo()!.endOfMonth, by: dayDurationInSeconds) {
            previousMonthDays.append(day)
        }
        
        previousMonthDays.removeFirst(previousMonthDays.count - (firstWeekDay - 1))
        
        for day in previousMonthDays {
            result.append(DayModel(id: day, secondary: true))
        }
        
        for day in stride(from: self.startOfMonth, to: self.endOfMonth, by: dayDurationInSeconds) {
            result.append(DayModel(id: day))
        }
        
        return result
    }
    
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var startOfMonth: Date {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
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
    
    func monthAgo() -> Date? {
        Calendar.current.date(byAdding: .month, value: -1, to: self)
    }
    
    func monthFurther() -> Date? {
        Calendar.current.date(byAdding: .month, value: 1, to: self)
    }
}

