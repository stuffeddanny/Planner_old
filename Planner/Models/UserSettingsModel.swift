//
//  UserSettingsModel.swift
//  Planner
//
//  Created by Danny on 11/28/22.
//

import SwiftUI
import CloudKit

struct UserSettingsModel: Codable {
    var accentColor: Color = Color(.sRGB, red: 1, green: 0.396, blue: 0.392, opacity: 1)
    var selectedDayColor: Color = Color(.sRGB, red: 1, green: 0.396, blue: 0.392, opacity: 1)
    var weekendsColor: Color = .red
    var backgroundColor: Color = .clear
    var todaysDayColor: Color = .pink
    var isTodayInverted: Bool = false
    var isSelectedDayInverted: Bool = false
    var syncThroughICloudEnabled: Bool = true
    var gapBetweenDays: Int = 20
    var tags: [Tag] = [
        Tag(text: "Work", color: .blue),
        Tag(text: "Study", color: .green)
    ]
    var modifiedDate: Date
}

extension UserSettingsModel {
    var record: CKRecord? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        let record = CKRecord(recordType: "UserSettingsModel", recordID: .init(recordName: "UserSettings"))
        record["model"] = data
        return record
    }
}


