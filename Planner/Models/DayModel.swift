//
//  DayModel.swift
//  Planner
//
//  Created by Danny on 12/24/22.
//

import SwiftUI
import CloudKit

struct DayModel: Identifiable, Equatable, Codable, Sendable {
    
    let id: Date
    var reminders: [Reminder]
    var dateModified: Date
    
}

extension DayModel {
    var record: CKRecord {
        let record = CKRecord(recordType: "DayModel", recordID: CKRecord.ID(recordName: self.id.idFromDate))
        record["reminders"] = self.reminders.compactMap({ try? JSONEncoder().encode($0) })
        record["dateModified"] = self.dateModified
        return record
    }
}

struct DayModelHolder: Codable {
    let models: [DayModel]
}
