//
//  ReminderCompletionCircleView.swift
//  Planner
//
//  Created by Danny on 12/1/22.
//

import SwiftUI

struct ReminderCompletionCircleView: View {
    
    @Binding var completed: Bool
    let color: Color
    
    var body: some View {
        Circle()
            .strokeBorder(completed ? color : Color.secondary, lineWidth: 1.5)
            .background(
                Circle().foregroundColor(completed ? color : Color.clear)
                    .padding(4)
            )
    }
}

struct ReminderCompletionCircleView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderCompletionCircleView(completed: .constant(true), color: .accentColor)
    }
}
