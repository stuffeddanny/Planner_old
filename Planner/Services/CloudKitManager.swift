//
//  CloudKitManager.swift
//  Planner
//
//  Created by Danny on 12/23/22.
//

import CloudKit
import SwiftUI
import Combine

final actor CloudKitManager {
    
    static let instance = CloudKitManager()
    
    private init() {}
    
    
    
    
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
