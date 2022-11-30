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
            CalendarView()
                .navigationTitle("Calendar")
                .toolbar(.hidden, for: .navigationBar)
                .toolbar { getToolbar() }
                .background(settingManager.settings.backgroundColor)
        }
        .tint(settingManager.settings.accentColor)
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
