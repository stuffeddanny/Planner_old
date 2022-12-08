//
//  CalendarView.swift
//  Planner
//
//  Created by Danny on 12/7/22.
//

import SwiftUI

struct CalendarView: View {
    
    @EnvironmentObject private var settingManager: SettingManager
    
    @StateObject private var vm = CalendarViewModel()
    
    @State private var scrollIsDisabled: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            
            TopLine
            
            WeekNames
                .padding(.top)
            
            DaysGrid
                .offset(vm.offset)
                .opacity(vm.opacity)
                .gesture(swipeGesture)
                .frame(maxHeight: vm.weekView ? 50 : .infinity)
            
            if let day = vm.selectedDay, vm.showReminder {
                
                Divider()

                ReminderList(reminders: $vm.remindersOnTheScreen, for: day)
            }
            
            Spacer(minLength: 0)
        }
        .toolbar { getToolBar() }
        .background(settingManager.settings.backgroundColor)
        .onAppear {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    @ToolbarContentBuilder
    private func getToolBar() -> some ToolbarContent {
        ToolbarItem(placement: .status) {
            Button("Today") {
                vm.goTo(Date().startOfDay)
            }
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

    private func getTagsColors(for day: DayModel) -> [Color] {
        if vm.weekView {
            return []
        }
        let reminders = vm.reminders[day.id] ?? []
        let ids = reminders.compactMap({ $0.tagId })
        
        if !reminders.isEmpty && ids.isEmpty {
            return [.secondary]
        }
        
        return ids.compactMap({ id in
            settingManager.settings.tags.first(where: { $0.id == id })?.color }).uniqueElements()
    }

    private var DaysGrid: some View {
        GeometryReader { safeProxy in
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: .init(repeating: GridItem(alignment: .top), count: 7)) {
                    ForEach(vm.days) { day in
                        DayView(for: day, isSelected: vm.isDaySelected(day), isToday: vm.isToday(day), with: getTagsColors(for: day))
                            .onTapGesture { onTapFunc(day) }
                            .frame(maxWidth: .infinity)
                            .frame(height: 45 + CGFloat(settingManager.settings.gapBetweenDays), alignment: .top) // Gaps betweenDays
                            .padding(.top, 5)
                        
                    }
                }
                .background(
                    GeometryReader { actualProxy in
                        Color.clear
                            .onAppear {
                                checkForScroll(actualHeight: actualProxy.size.height, safeHeight: safeProxy.size.height)
                            }
                            .onChange(of: actualProxy.size.height) { newValue in
                                checkForScroll(actualHeight: newValue, safeHeight: safeProxy.size.height)
                            }
                    }
                )
            }
            
            .scrollDisabled(vm.weekView || scrollIsDisabled)
        }
    }
    
    private func onTapFunc(_ day: DayModel) {
        if day.secondary {
            vm.goTo(day.id)
        } else if vm.selectedDay == day {
            vm.unselect()
        } else {
            vm.select(day)
        }
    }
    
    private func checkForScroll(actualHeight: Double, safeHeight: Double) {
        scrollIsDisabled = actualHeight < safeHeight
    }

    
    private var WeekNames: some View {
        LazyVGrid(columns: .init(repeating: GridItem(alignment: .center), count: 7)) {
            ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekDay in
                Text(weekDay)
                    .foregroundColor(weekDay == "Sat" || weekDay == "Sun" ? settingManager.settings.weekendsColor : .secondary)
                    .lineLimit(1)
            }
        }
    }
    
    private var TopLine: some View {
        HStack {
            Text(vm.monthName)
                .lineLimit(1)
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
    }
}
