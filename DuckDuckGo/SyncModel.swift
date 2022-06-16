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
        isAuthenticated = sync.isAuthenticated
    }
    
    func disconnect() {
        try? sync.disconnect()
        self.isAuthenticated = false
    }
    
    func createAccount() {
        isBusy = true
        errorMessage = ""

        Task {
            do {
                try await allocateUUIDsToBookmarks()
                try await sync.createAccount(deviceName: deviceName)
                isAuthenticated = sync.isAuthenticated
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
            } catch {
                errorMessage = "\(error)"
            }
            isBusy = false
        }
    }

    func allocateUUIDsToBookmarks() async throws {
        try await BookmarksManager().assignUUIDsWhereNeeded()
    }
    
}

extension BookmarksManager {
 
    func assignUUIDsWhereNeeded() async throws {
        try await coreDataStorage.assignUUIDsWhereNeeded()
    }
    
}
