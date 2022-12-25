//
//  PlannerApp.swift
//  Planner
//
//  Created by Danny on 11/25/22.
//

import SwiftUI

@main
struct PlannerApp: App {
    
    @State private var showLaunchView: Bool = true
        
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainScreenView()
                
                if showLaunchView {
                    LaunchView(showLaunchView: $showLaunchView)
                        .transition(.asymmetric(insertion: .identity, removal: .move(edge: .leading)))
                        .zIndex(2.0)
                }
            }
        }
    }
}
