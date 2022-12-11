//
//  LargeSizeView.swift
//  PlannerWidgetExtension
//
//  Created by Danny on 12/10/22.
//

import SwiftUI
import WidgetKit

struct LargeSizeView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack {
            HStack {
                Text("My reminders")
                
                Text(Date.now, format: .dateTime)
                
                Spacer()
            }
            .clipped()
            .shadow(radius: 5)
            
            ForEach(entry.reminders) { reminder in
                Link(destination: URL(string: "planner://reminder/\(reminder.id.uuidString)")!) {
                    HStack {
                        Circle()
                            .stroke(lineWidth: 2)
                            .frame(width: 30, height: 30)
                            .overlay {
                                if reminder.completed {
                                    Image(systemName: "checkmark")
                                }
                            }
                        
                        Text(reminder.headline)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                Divider()
            }
        }
    }
}
