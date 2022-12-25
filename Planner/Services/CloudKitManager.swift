//
//  CloudKitManager.swift
//  Planner
//
//  Created by Danny on 12/23/22.
//

import CloudKit
import SwiftUI
import Combine
import WidgetKit

final actor CloudKitManager {
    
    static let instance = CloudKitManager()
        
    private var syncTask: Task<Void, Never>? = nil
    
    nonisolated var dayModels: [DayModel] {
        get {
            syncFromUserDefaults()
        }
        set {
            syncToUserDefaults(newValue)
        }
    }

    
    private init() {}
    
    nonisolated func syncToUserDefaults(_ value: [DayModel]) {
        if let defs = UserDefaults(suiteName: "group.plannerapp"),
           let encodedHolder = try? JSONEncoder().encode(DayModelHolder(models: value)) {
            defs.set(encodedHolder, forKey: "DayModelHolder")
        }
    }
    
    nonisolated func syncFromUserDefaults() -> [DayModel] {
        let encodedHolder = UserDefaults(suiteName: "group.plannerapp")?.data(forKey: "DayModelHolder") ?? .init()
        
        let holder = try? JSONDecoder().decode(DayModelHolder.self, from: encodedHolder)

        return holder?.models ?? []
    }
    
    func syncToCloud(_ value: [DayModel]) async {
        try? await CKContainer.default().privateCloudDatabase.modifyRecords(saving: value.filter({ !$0.reminders.isEmpty }).map({ $0.record }), deleting: value.filter({ $0.reminders.isEmpty }).map({ $0.record.recordID }), savePolicy: .changedKeys, atomically: false)

    }

    func syncFromCloud() async -> Result<[DayModel], Never> {
        await withCheckedContinuation { continuation in
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "DayModel", predicate: predicate)
            
            CKContainer.default().privateCloudDatabase.fetch(withQuery: query) { result in
                switch result {
                case .success(let returnedValue):
                    let records = returnedValue.matchResults.compactMap { value in
                        switch value.1 {
                        case .success(let record):
                            return record
                        case .failure(_):
                            return nil
                        }
                    }
                    
                    let dayModels = records.compactMap { record in
                        if let id = Date.dateFromId(record.recordID.recordName),
                           let encodedReminders = record["reminders"] as? [Data] {
                            let reminders = encodedReminders.compactMap({ try? JSONDecoder().decode(Reminder.self, from: $0)})
                            return DayModel(id: id, reminders: reminders)
                        } else {
                            return nil
                        }
                    }
                    
                    continuation.resume(returning: .success(dayModels))
                    
                case .failure(_):
                    break
                }
            }
        }
    }
    
    func getFromCloudWith(id: Date) async -> Result<DayModel?, Error> {
        await withCheckedContinuation { continuation in
            CKContainer.default().privateCloudDatabase.fetch(withRecordID: .init(recordName: id.idFromDate)) { returnedRecord, error in
                if let error = error {
                    continuation.resume(returning: .failure(error))
                } else if let record = returnedRecord,
                          let id = Date.dateFromId(record.recordID.recordName),
                          let encodedReminders = record["reminders"] as? [Data] {
                    let reminders = encodedReminders.compactMap({ try? JSONDecoder().decode(Reminder.self, from: $0)})
                    continuation.resume(returning: .success(DayModel(id: id, reminders: reminders)))
                } else {
#warning("Fix")
                    continuation.resume(returning: .success(nil))
                }
            }
        }
    }
    
    func getICloudStatus() async -> Result<CKAccountStatus, Error> {
        await withCheckedContinuation { continuation in
            CKContainer.default().accountStatus { iCloudStatus, error in
                if let error = error {
                    continuation.resume(returning: .failure(error))
                } else {
                    continuation.resume(returning: .success(iCloudStatus))
                }
            }
        }
    }
}
