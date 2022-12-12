//
//  PlannerWidget.swift
//  PlannerWidget
//
//  Created by Danny on 12/8/22.
//

import WidgetKit
import SwiftUI

@main
struct PlannerWidget: Widget {
    let kind: String = "PlannerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName("Planner Widget")
        .description("Keep your reminders close to you")
    }
}
