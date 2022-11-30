//
//  CalendarView.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

struct CalendarView: View {
    
    @EnvironmentObject private var settingManager: SettingManager
        
    @StateObject private var vm = CalendarViewModel()
            
    var body: some View {
        VStack(spacing: 0) {
            
            // Month and year
            topLine
            
            // Weekdays names row
            weekNames
                .padding(.top)
            
            Divider()
            
            calendarDays
                .offset(vm.offset)
                .opacity(vm.opacity)
                .gesture(swipeGesture)
            
            Spacer(minLength: 0)
        }
    }
    
    private var calendarDays: some View {
//        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: .init(repeating: GridItem(alignment: .top), count: 7)) {
                ForEach(vm.days) { day in
                    DayView(for: day, isSelected: vm.isDaySelected(day), isToday: vm.isToday(day))
                        .onTapGesture { onTapFunc(day) }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .frame(height: CGFloat(settingManager.settings.gapBetweenDays), alignment: .top) // Gaps betweenDays
                        .padding(.top, 5)
                    
                }
            }
//        }
//        .scrollDisabled(true)
    }
    
    private func onTapFunc(_ day: DayModel) {
        if day.secondary {
            vm.goTo(day.id)
        } else if vm.isDaySelected(day) {
            vm.unselect()
        } else {
            vm.select(day)
        }
    }
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                withAnimation(DevPrefs.slidingAfterFingerAnimation) {
                    vm.offset.width = value.translation.width * DevPrefs.slidingAfterFingerFactor
                }
            }
            .onEnded { value in
                if abs(value.translation.width) > UIScreen.main.bounds.width * DevPrefs.screenWidthFactor ||
                    abs(value.predictedEndTranslation.width) > UIScreen.main.bounds.width * DevPrefs.screenWidthFactor {
                    if value.translation.width < 0 {
                        vm.goTo(vm.weekView ? vm.firstDayOfUnitOnTheScreenDate.weekFurther() : vm.firstDayOfUnitOnTheScreenDate.monthFurther())
                    } else {
                        vm.goTo(vm.weekView ? vm.firstDayOfUnitOnTheScreenDate.weekAgo() : vm.firstDayOfUnitOnTheScreenDate.monthAgo())
                    }
                } else {
                    withAnimation(DevPrefs.slidingToStartPositionAnimation) {
                        vm.offset.width = .zero
                    }
                }
            }
    }
    

    
    private var weekNames: some View {
        LazyVGrid(columns: .init(repeating: GridItem(alignment: .center), count: 7)) {
            ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekDay in
                Text(weekDay)
                    .foregroundColor(weekDay == "Sat" || weekDay == "Sun" ? settingManager.settings.weekendsColor : .secondary)
                    .lineLimit(1)
            }
        }
    }

    
    private var topLine: some View {
        HStack {
            Text(vm.monthName)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(settingManager.settings.accentColor)
                .padding(.horizontal)
                .onTapGesture {
                    vm.unselect()
                }
                .contextMenu {
                    ForEach(Calendar.current.monthSymbols, id: \.self) { monthName in
                        Button(monthName) {
                            let form = DateFormatter()
                            form.dateFormat = "MMMM"

                            vm.goTo(Calendar.current.date(from: DateComponents(
                                year: Calendar.current.component(.year, from: vm.firstDayOfUnitOnTheScreenDate),
                                month: Calendar.current.component(.month, from: form.date(from: monthName) ?? .now)
                            ))!)

                        }
                    }
                }
            
            Spacer(minLength: 0)
            
            Text(vm.yearName)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(settingManager.settings.accentColor)
                .padding(.horizontal)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(SettingManager())
    }
}
