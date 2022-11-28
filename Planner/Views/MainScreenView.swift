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
            VStack {
                CalendarView(for: vm.firstDayOfMonthOnTheScreenDate)
                    .offset(vm.offset)
                    .opacity(vm.opacity)
                    .environmentObject(vm)
                    
                
                HStack {
                    Button {
                        vm.goTo(vm.firstDayOfMonthOnTheScreenDate.monthAgo())
                    } label: {
                        Text("Previous")
                            .frame(width: 70)
                    }
                    
                    
                    Spacer(minLength: 0)
                    
                    Button {
                        vm.goTo(vm.firstDayOfMonthOnTheScreenDate.monthFurther())
                    } label: {
                        Text("Next")
                            .frame(width: 70)
                    }
                    
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Calendar")
            .toolbar(.hidden, for: .navigationBar)
            .toolbar { getToolbar() }
            .toolbarBackground(.red, for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
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
