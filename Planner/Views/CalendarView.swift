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
    
    @State private var offset: CGSize = .zero
    
    init(for date: Date) {
        _vm = .init(wrappedValue: CalendarViewModel(for: date))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            topLine
            
            LazyVGrid(columns: .init(repeating: GridItem(alignment: .center), count: 7)) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { weekDay in
                    Text(weekDay)
                        .foregroundColor(weekDay == "Sat" || weekDay == "Sun" ? .red.opacity(0.6) : .secondary)
                        .lineLimit(1)
                }
                .padding(.vertical, 5)
            }
         
            Divider()
            
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
            .offset(offset)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        withAnimation {
                            offset.width = value.translation.width
                        }
                        print(value.translation)
                    })
                    .onEnded({ value in
                        if value.translation.width > UIScreen.main.bounds.width * 0.5 {
                            
                        } else {
                            withAnimation {
                                offset.width = .zero
                            }
                        }
                    })
            )
            
            Spacer(minLength: 0)
        }
    }
    
    private var topLine: some View {
        HStack {
            Text(vm.monthName)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
                .padding(.leading)
                .contextMenu {
                    ForEach(Calendar.current.monthSymbols, id: \.self) { monthName in
                        Button(monthName) {
                            let form = DateFormatter()
                            form.dateFormat = "MMMM"

                            mainVm.goTo(Calendar.current.date(from: DateComponents(
                                year: Calendar.current.component(.year, from: mainVm.firstDayOfMonthOnTheScreenDate),
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
                .padding(.trailing)
        }
    }

}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(for: .now)
    }
}
