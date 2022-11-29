//
//  CalendarView.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

struct CalendarView: View {
    
    @EnvironmentObject private var mainVm: MainScreenViewModel
    @EnvironmentObject private var manager: SettingManager
    
    @ObservedObject private var vm: CalendarViewModel
        
    init(for date: Date) {
        _vm = .init(wrappedValue: CalendarViewModel(for: date))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: .init(repeating: GridItem(alignment: .top), count: 7)) {
                ForEach(vm.days) { day in
                    DayView(for: day, isSelected: vm.isDaySelected(day), isToday: vm.isToday(day))
                        .onTapGesture {
                            day.secondary ? mainVm.goTo(day.id) : vm.isDaySelected(day) ? vm.unselect(day) : vm.select(day)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .frame(height: CGFloat(manager.settings.gapBetweenDays), alignment: .top) // Gaps betweenDays
                        .padding(.top, 5)
                    
                }
            }
        }
        .scrollDisabled(true)
    }
    
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(for: .now)
    }
}
