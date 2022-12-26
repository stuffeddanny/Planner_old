//
//  CloudManager.swift
//  Planner
//
//  Created by Danny on 12/25/22.
//

import CloudKit
import Combine
import SwiftUI

enum CloudManagerError: Error {
    case errorDecodingSettings
    case errorGettingRecordFromUserSettings
    case errorSavingSettings
    case errorSavingDayModels
    case errorDecodingDayModel
}

actor CloudManager {
    
    static let instance = CloudManager()
    
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    
    private init() {}
    
    func syncSettingsFromCloud() async -> Result<UserSettingsModel, Error> {
        await withCheckedContinuation { continuation in
            privateDatabase.fetch(withRecordID: .init(recordName: "UserSettings")) { returnedRecord, error in
                if let error = error {
                    continuation.resume(returning: .failure(error))
                } else if let record = returnedRecord,
                          let encodedModel = record["model"] as? Data,
                          let model = try? JSONDecoder().decode(UserSettingsModel.self, from: encodedModel) {
                    continuation.resume(returning: .success(model))
                } else {
                    continuation.resume(returning: .failure(CloudManagerError.errorDecodingSettings))
                }
            }
        }
    }
    
    func syncToCloud(_ value: UserSettingsModel) async -> Result<CKRecord, Error> {
        guard let recordToSave = value.record else { return .failure(CloudManagerError.errorGettingRecordFromUserSettings) }
        switch try? await privateDatabase.modifyRecords(saving: [recordToSave], deleting: [], savePolicy: .changedKeys).saveResults {
        case .some(let dict):
            if let result = dict.first?.value {
                return result
            } else {
                return .failure(CloudManagerError.errorSavingSettings)
            }
        case .none:
            return .failure(CloudManagerError.errorSavingSettings)
        }
        
    }
    
    func syncToCloud(_ value: [DayModel]) async -> Result<[CKRecord.ID : Result<CKRecord, Error>], Error> {
        switch try? await privateDatabase.modifyRecords(
            saving: value.map({ $0.record }),
            deleting: [],
            savePolicy: .changedKeys,
            atomically: false) {
            
        case .some(let results):
            return .success(results.saveResults)
            
        case .none:
            return .failure(CloudManagerError.errorSavingDayModels)
        }
    }

    func syncDayModelsFromCloud() async -> Result<[DayModel], Error> {
        await withCheckedContinuation { continuation in
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "DayModel", predicate: predicate)
            
            privateDatabase.fetch(withQuery: query) { result in
                switch result {
                case .success(let result):
                    let dayModels = result.matchResults.compactMap { result in
                        if let record = try? result.1.get(),
                           let id = Date.dateFromId(record.recordID.recordName),
                           let encodedReminders = record["reminders"] as? [Data],
                           let dateModified = record["dateModified"] as? Date {
                            let reminders = encodedReminders.compactMap({ try? JSONDecoder().decode(Reminder.self, from: $0)})
                            return DayModel(id: id, reminders: reminders, dateModified: dateModified)
                        } else {
                            return nil
                        }
                    }
                    
                    continuation.resume(returning: .success(dayModels))
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
    
    func getFromCloudWith(id: Date) async -> Result<DayModel, Error> {
        await withCheckedContinuation { continuation in
            privateDatabase.fetch(withRecordID: .init(recordName: id.idFromDate)) { returnedRecord, error in
                if let error = error {
                    continuation.resume(returning: .failure(error))
                } else if let record = returnedRecord,
                          let id = Date.dateFromId(record.recordID.recordName),
                          let encodedReminders = record["reminders"] as? [Data],
                          let dateModified = record["dateModified"] as? Date {
                    let reminders = encodedReminders.compactMap({ try? JSONDecoder().decode(Reminder.self, from: $0)})
                    continuation.resume(returning: .success(DayModel(id: id, reminders: reminders, dateModified: dateModified)))
                } else {
                    continuation.resume(returning: .failure(CloudManagerError.errorDecodingDayModel))
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
