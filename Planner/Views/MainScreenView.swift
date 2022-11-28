//
//  MainScreenView.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

struct MainScreenView: View {
    
    @StateObject private var vm = MainScreenViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Month and year
                topLine
                
                // Weekdays
                LazyVGrid(columns: .init(repeating: GridItem(alignment: .center), count: 7)) {
                    ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekDay in
                        Text(weekDay)
                            .foregroundColor(weekDay == "Sat" || weekDay == "Sun" ? .red.opacity(0.6) : .secondary)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 5)
                }
             
                Divider()

                // Days
                CalendarView(for: vm.firstDayOfMonthOnTheScreenDate)
                    .offset(vm.offset)
                    .opacity(vm.opacity)
                    .environmentObject(vm)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged({ value in
                                withAnimation {
                                    vm.offset.width = value.translation.width
                                }
                            })
                            .onEnded({ value in
                                if abs(value.translation.width) > UIScreen.main.bounds.width * 0.5 {
                                    if value.translation.width < 0 {
                                        vm.goTo(vm.firstDayOfMonthOnTheScreenDate.monthFurther())
                                    } else {
                                        vm.goTo(vm.firstDayOfMonthOnTheScreenDate.monthAgo())
                                    }
                                } else {
                                    withAnimation {
                                        vm.offset.width = .zero
                                    }
                                }
                            })
                    )
                
                Spacer(minLength: 0)

            }
            .navigationTitle("Calendar")
            .toolbar(.hidden, for: .navigationBar)
            .toolbar { getToolbar() }
        }
    }
    
    private var topLine: some View {
        HStack {
            Text(vm.monthName)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
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
                .foregroundColor(.accentColor)
                .padding(.horizontal)
        }
    }
    
    @ToolbarContentBuilder
    private func getToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            
            Spacer(minLength: 0)
            
            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape")
                    .foregroundColor(.accentColor)
            }

            
        }
    }
}

struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
    }
}
