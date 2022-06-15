//
//  DDGSyncExtension.swift
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

class SyncPersistence: LocalDataPersisting {
    
    @UserDefaultsWrapper(key: .syncBookmarksLastModified, defaultValue: nil)
    var bookmarksLastModified: String?
    
    func persistDevices(_ devices: [RegisteredDevice]) async throws {
    }
    
    func persistEvents(_ events: [SyncEvent]) async throws {
        
        for event in events {
            switch event {
            case .bookmarkUpdated(let savedSiteItem):
                await BookmarksManager().updateSavedSiteItem(savedSiteItem)
                
            case .bookmarkFolderUpdated(let savedSiteFolder):
                await BookmarksManager().updateSavedSiteFolder(savedSiteFolder)
                
            case .bookmarkDeleted(let id):
                await BookmarksManager().deleteItemWithUUID(id)
                
            }
        }
        
    }
    
    func updateBookmarksLastModified(_ lastModified: String?) {
        bookmarksLastModified = lastModified
    }
    
}

extension DDGSync {
    
    static let queue = DispatchQueue(label: "Sync Operations")
    
    convenience init() {
        self.init(persistence: SyncPersistence())
    }
    
}

extension DDGSyncing {
    
    func persistBookmark(_ bookmark: BookmarkManagedObject, fromBookmarksManager manager: BookmarksManager) {
        guard isAuthenticated else { return }
        
        Task {
            guard let id = bookmark.uuid?.uuidString,
                  let title = bookmark.title,
                  let url = bookmark.url?.absoluteString else { return }
            
            let nextItem = manager.nextItemUUIDForBookmark(bookmark)?.uuidString
            let parent = bookmark.parent?.uuid
            
            let savedSite = SavedSiteItem(id: id,
                                          title: title,
                                          url: url,
                                          isFavorite: false,
                                          nextFavorite: nil,
                                          nextItem: nextItem,
                                          parent: parent?.uuidString)
            do {
                try await sender()
                    .persistingBookmark(savedSite)
                    .send()
            } catch {
                // TODO: log this
            }
        }
        
     }
    
}

extension BookmarksManager {
    
    func nextItemUUIDForBookmark(_ bookmark: BookmarkManagedObject) -> UUID? {
        if let folder = bookmark.parent,
           let index = folder.children?.index(of: bookmark) {
            let item = folder.children?.object(at: index + 1) as? BookmarkItemManagedObject
            return item?.uuid
        }
        return nil
    }
    
    func updateSavedSiteItem(_ item: SavedSiteItem) async {
    }
    
    func updateSavedSiteFolder(_ folder: SavedSiteFolder) async {
    }
    
    func deleteItemWithUUID(_ uuidString: String) async {
    }
    
}
