//
//  WidgetView.swift
//  PlannerWidgetExtension
//
//  Created by Danny on 12/10/22.
//

import SwiftUI
import WidgetKit

struct WidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: SimpleEntry

    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            MediumSizeView(entry: entry)
        case .systemLarge:
            LargeSizeView(entry: entry)
        default:
            Text("Not implemented")
        }
    }
}
