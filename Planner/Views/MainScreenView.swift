//
//  MainScreenView.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

struct MainScreenView: View {
    
    @EnvironmentObject private var settingManager: SettingManager
    
    @StateObject private var vm = MainScreenViewModel()
    
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 0) {
                
                // Month and year
                topLine
                
                // Weekdays names row
                weekNames
                .padding(.top)
             
                Divider()

                // Calendar
                CalendarView(for: vm.firstDayOfMonthOnTheScreenDate)
                    .offset(vm.offset)
                    .opacity(vm.opacity)
                    .environmentObject(vm)
                    .gesture(swipeGesture)
                
                Spacer(minLength: 0)

            }
            .navigationTitle("Calendar")
            .toolbar(.hidden, for: .navigationBar)
            .toolbar { getToolbar() }
            .background(settingManager.settings.backgroundColor)
        }
        .tint(settingManager.settings.accentColor)
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
                        vm.goTo(vm.firstDayOfMonthOnTheScreenDate.monthFurther())
                    } else {
                        vm.goTo(vm.firstDayOfMonthOnTheScreenDate.monthAgo())
                    }
                } else {
                    withAnimation(DevPrefs.slidingToStartPositionAnimation) {
                        vm.offset.width = .zero
                    }
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
                .contextMenu {
                    ForEach(Calendar.current.monthSymbols, id: \.self) { monthName in
                        Button(monthName) {
                            let form = DateFormatter()
                            form.dateFormat = "MMMM"

                            vm.goTo(Calendar.current.date(from: DateComponents(
                                year: Calendar.current.component(.year, from: vm.firstDayOfMonthOnTheScreenDate),
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
    
    @ToolbarContentBuilder
    private func getToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            
            Spacer(minLength: 0)
            
            NavigationLink {
                SettingsView(settingManager)
            } label: {
                Image(systemName: "gearshape")
                    .foregroundColor(settingManager.settings.accentColor)
            }

            
        }
    }
}

struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
            .environmentObject(SettingManager())
    }
}
