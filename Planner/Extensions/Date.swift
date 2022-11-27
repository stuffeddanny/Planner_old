//
//  Date.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import Foundation

extension Date {
    
    
    func getDays() -> [DayModel] {
        let calendar = Calendar.current

        var result: [DayModel] = []

        let startOfCurrentMonth = self.startOfMonth
        let startOfPrevMonth = self.monthAgo().startOfMonth

        let firstWeekDay = calendar.component(.weekday, from: startOfCurrentMonth)

        if firstWeekDay > 1 {
            let lastDayOfPrevMonth = startOfPrevMonth.endOfMonth.startOfDay
            
            for index in -(firstWeekDay-2)...0 {
                result.append(DayModel(id: calendar.date(byAdding: .day, value: index, to: lastDayOfPrevMonth)!, secondary: true))
            }
        }

        for day in calendar.range(of: .day, in: .month, for: startOfCurrentMonth)! {
            result.append(DayModel(id: calendar.date(byAdding: .day, value: day - 1, to: startOfCurrentMonth)!))
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
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        
        return Calendar.current.date(from: components)!
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
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
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
        Calendar.current.date(byAdding: .month, value: -1, to: self)!
    }
    
    func monthFurther() -> Date {
        Calendar.current.date(byAdding: .month, value: 1, to: self)!
    }
}

