//
//  MainScreenView.swift
//  Planner
//
//  Created by Danny on 11/25/22.r
//

import SwiftUI

struct MainScreenView: View {
    
    @StateObject private var settingManager = SettingManager.instance
    
    @StateObject private var vm = MainScreenViewModel()
        
    var body: some View {
        NavigationStack {
            CalendarView()
                .navigationTitle("Calendar")
                .toolbar(.hidden, for: .navigationBar)
                .background(settingManager.settings.backgroundColor)
                .toolbar { getToolbar() }
        }
        .tint(settingManager.settings.accentColor)
    }
    
    @ToolbarContentBuilder
    private func getToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            
            Color.clear
            
            NavigationLink {
                SettingsView()
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
    }
}
