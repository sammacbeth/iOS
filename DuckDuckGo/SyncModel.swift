//
//  SyncModel.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import DDGSync
import UIKit
import Core

@MainActor
class SyncModel: ObservableObject {
     
    @Published var isAuthenticated = false
    @Published var isBusy = false
    @Published var isScanning = false
    
    @Published var recoveryCode: Data = Data()
    @Published var scannedCode: Data = Data() {
        didSet {
            // TODO 
        }
    }
    
    @Published var showErrorMessage = false
    @Published var errorMessage = "" {
        didSet {
            showErrorMessage = !errorMessage.isEmpty
        }
    }
    
    let sync: DDGSyncing
    let deviceName: String
    
    init(sync: DDGSyncing, deviceName: String) {
        self.sync = sync
        self.deviceName = deviceName
        refreshAuthStatus()
    }

    func connectWithRecoveryCode(_ code: String) {
        guard let data = Data(base64Encoded: code) else {
            errorMessage = "Invalid recovery code (1)"
            return
        }

        Task {
            do {
                try await sync.login(recoveryKey: data, deviceName: deviceName)
                isAuthenticated = isAuthenticated
            } catch {
                errorMessage = "\(error)"
            }
        }

    }

    func disconnect() {
        try? sync.disconnect()
        refreshAuthStatus()
    }
    
    func createAccount() {
        isBusy = true
        errorMessage = ""

        Task {
            do {
                try await allocateUUIDsToBookmarks()
                try await sync.createAccount(deviceName: deviceName)
                refreshAuthStatus()
            } catch {
                errorMessage = "\(error)"
            }
            isBusy = false
        }
    }
    
    func startScanning() {
    }
    
    func fetchNow() {
        isBusy = true
        errorMessage = ""
        
        Task {
            do {
                try await allocateUUIDsToBookmarks()
                try await sync.fetchLatest()
                refreshAuthStatus()
            } catch {
                errorMessage = "\(error)"
            }
            isBusy = false
        }
    }

    private func refreshAuthStatus() {
        isAuthenticated = sync.isAuthenticated
        recoveryCode = sync.recoveryCode ?? Data()
    }

    private func allocateUUIDsToBookmarks() async throws {
        try await BookmarksManager().assignUUIDsWhereNeeded()
    }
    
}

extension BookmarksManager {
 
    func assignUUIDsWhereNeeded() async throws {
        try await coreDataStorage.assignUUIDsWhereNeeded()
    }
    
}
