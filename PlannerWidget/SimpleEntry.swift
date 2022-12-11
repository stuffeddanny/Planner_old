//
//  SimpleEntry.swift
//  PlannerWidgetExtension
//
//  Created by Danny on 12/10/22.
//

import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let reminders: [Reminder]
}
