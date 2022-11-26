//
//  MainScreenView.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

final class MainScreenViewModel: ObservableObject {
    
    @Published var dateOnTheScreen: Date
    @Published var offset = CGSize()
    @Published var opacity: Double = 1
    @Published var selectedDay: Date? = nil

    init() {
        dateOnTheScreen = .now
    }
    
    func previous() {
        withAnimation {
            offset = CGSize(width: UIScreen.main.bounds.size.width, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dateOnTheScreen = self.dateOnTheScreen.monthAgo()!
            self.opacity = 0
            self.offset = CGSize()
            withAnimation {
                self.opacity = 1
            }
        }
        
    }
    
    func select(_ date: Date) {
        withAnimation {
            selectedDay = date
        }
    }
    
    func next() {
        withAnimation {
            offset = CGSize(width: -UIScreen.main.bounds.size.width, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dateOnTheScreen = self.dateOnTheScreen.monthFurther()!
            self.opacity = 0
            self.offset = CGSize()
            withAnimation {
                self.opacity = 1
            }
        }
    }
    
    func isDaySelected(_ day: DayModel) -> Bool {
        guard let selectedDay = selectedDay else { return false }
        return Calendar.current.isDate(day.id, equalTo: selectedDay, toGranularity: .day)
    }
}

struct MainScreenView: View {
    
    @StateObject private var vm = MainScreenViewModel()
    
    var body: some View {
            VStack {
                CalendarView(for: vm.dateOnTheScreen)
                    .offset(vm.offset)
                    .opacity(vm.opacity)
                    .environmentObject(vm)
                
                HStack {
                    Button {
                        vm.previous()
                    } label: {
                        Text("Previous")
                            .frame(width: 70)
                    }
                    
                    
                    Spacer(minLength: 0)
                    
                    Button {
                        vm.next()
                    } label: {
                        Text("Next")
                            .frame(width: 70)
                    }
                    
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
    }
}

struct MainScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreenView()
    }
}
