//
//  CalendarView.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

struct DayModel: Identifiable {
    let id: Date
    let secondary: Bool
    
    init(id: Date, secondary: Bool = false) {
        self.id = id
        self.secondary = secondary
    }
}

struct CalendarView: View {
    
    @EnvironmentObject private var mainVm: MainScreenViewModel
    
    private let monthName: String
    private let yearName: String
    private let days: [DayModel]
    
    init(for date: Date) {
        monthName = date.month
        yearName = date.year
        var result: [DayModel] = []
        
        let dayDurationInSeconds: TimeInterval = 60*60*24
        
        let firstWeekDay = Calendar.current.component(.weekday, from: date.startOfMonth)
        
        var previousMonthDays: [Date] = []
        
        for day in stride(from: date.monthAgo()!.startOfMonth, to: date.monthAgo()!.endOfMonth, by: dayDurationInSeconds) {
            previousMonthDays.append(day)
        }
        
        previousMonthDays.removeFirst(previousMonthDays.count - (firstWeekDay - 1))
        
        for day in previousMonthDays {
            result.append(DayModel(id: day, secondary: true))
        }
        
        for day in stride(from: date.startOfMonth, to: date.endOfMonth, by: dayDurationInSeconds) {
            result.append(DayModel(id: day))
        }
        
        days = result
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(monthName)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .padding(.leading)
                    
                
                Spacer(minLength: 0)
                
                Text(yearName)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .padding(.trailing)
            }
         
            LazyVGrid(columns: .init(repeating: GridItem(alignment: .center), count: 7)) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekDay in
                    Text(weekDay)
                        .foregroundColor(weekDay == "Sat" || weekDay == "Sun" ? .red.opacity(0.6) : .secondary)
                        .lineLimit(1)
                }
                .padding(.bottom)
                
                
                ForEach(days) { day in
                    DayView(for: day, isSelected: mainVm.isDaySelected(day))
                        .onTapGesture {
                            day.secondary ? mainVm.previous() : mainVm.select(day.id)
                        }
                        .frame(width: 40, height: 40)
                }
            }
            
            Spacer(minLength: 0)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(for: .now)
    }
}
