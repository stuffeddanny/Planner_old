//
//  SettingsView.swift
//  Planner
//
//  Created by Danny on 11/28/22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            Text("settings")
        }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
    }
}







struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}
