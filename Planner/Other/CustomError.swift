//
//  CustomError.swift
//  Planner
//
//  Created by Danny on 12/29/22.
//

import Foundation

enum CustomError: LocalizedError {
    case noInternet
    case setToCloud
    case setSettingsToCloud
    case getFromCloud
    
    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "Reminders cannot be refreshed for some reason"
        case .setToCloud:
            return "Reminders cannot be synced to iCloud for some reason"
        case .setSettingsToCloud:
            return "Settings haven't been saved to iCloud"
        case .getFromCloud:
            return "Error while fetching reminders from your cloud"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        default:
            return "Check your account status and/or internet connection."
        }
    }
}
