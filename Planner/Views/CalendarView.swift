//
//  CalendarView.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

struct CalendarView: View {
    
    @EnvironmentObject private var mainVm: MainScreenViewModel
    
    @ObservedObject private var vm: CalendarViewModel
        
    init(for date: Date) {
        _vm = .init(wrappedValue: CalendarViewModel(for: date))
    }
    
    var body: some View {
        
        //            ScrollView(showsIndicators: false) {
        LazyVGrid(columns: .init(repeating: GridItem(alignment: .top), count: 7)) {
            ForEach(vm.days) { day in
                DayView(for: day, isSelected: vm.isDaySelected(day))
                    .onTapGesture {
                        day.secondary ? mainVm.goTo(day.id) : vm.isDaySelected(day) ? vm.unselect(day) : vm.select(day)
                    }
                    .frame(width: 40, height: 40)
                    .frame(minHeight: 40, alignment: .top) // Gaps betweenDays
                    .padding(.top, 5)
            }
        }
        //            }
    }
    
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(for: .now)
    }
}
