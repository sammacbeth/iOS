//
//  SyncManager.swift
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
import Core

protocol SyncManaging {
    
    var sync: DDGSyncing { get }
    
}

class SyncManager: SyncManaging {
    
    class Persistence: LocalDataPersisting {
        
        @UserDefaultsWrapper(key: .syncBookmarksLastModified, defaultValue: nil)
        var bookmarksLastModified: String?
        
        func updateBookmarksLastModified(_ lastModified: String?) {
            bookmarksLastModified = lastModified
        }
        
        func persistEvents(_ events: [SyncEvent]) async throws {
        }
        
        func persistDevices(_ devices: [RegisteredDevice]) async throws {
        }
                
    }
    
    static let shared: SyncManaging = SyncManager()
    
    let sync: DDGSyncing = DDGSync(persistence: Persistence())

    private var isBusy: Bool = false
    private var timer: Timer?
    
    private init() {
    }
    
    // Should be called after db initialisation, etc
    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            Task {
                try await self.fetchNow()
            }
        }
    }
    
    func fetchNow() async throws {
        guard !isBusy else { return }
        isBusy = true
        if sync.isAuthenticated {
            do {
                try await sync.fetchLatest()
            } catch {
                isBusy = false
                throw error
            }
        }
        isBusy = false
    }
    
}
