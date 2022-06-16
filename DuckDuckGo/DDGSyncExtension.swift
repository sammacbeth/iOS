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
import CoreData

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
                BookmarksManager().deleteItemWithUUID(id)
                
            }
        }
        
    }
    
    func updateBookmarksLastModified(_ lastModified: String?) {
        bookmarksLastModified = lastModified
    }
    
}

extension DDGSync {
    
    convenience init() {
        self.init(persistence: SyncPersistence())
    }
    
}

extension DDGSyncing {

    func persistBookmarkWithId(_ id: NSManagedObjectID, fromBookmarksManager manager: BookmarksManager) {
        guard isAuthenticated else { return }

        DispatchQueue.main.async {

            guard let bookmark = manager.coreDataStorage.viewContext.object(with: id) as? BookmarkManagedObject,
                  let id = bookmark.uuid?.uuidString,
                  let title = bookmark.title,
                  let url = bookmark.url?.absoluteString else { return }

            let nextItem = nextItemUUIDForBookmark(bookmark)?.uuidString
            let parent = bookmark.parent?.uuid == manager.topLevelBookmarksFolder?.uuid ? nil : bookmark.parent?.uuid

            let savedSite = SavedSiteItem(id: id,
                                          title: title,
                                          url: url,
                                          isFavorite: false,
                                          nextFavorite: nil,
                                          nextItem: nextItem,
                                          parent: parent?.uuidString)

            Task {
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

    private func nextItemUUIDForBookmark(_ bookmark: BookmarkManagedObject) -> UUID? {
        if let folder = bookmark.parent,
           let index = folder.children?.index(of: bookmark),
           let count = folder.children?.count,
           count < index + 1 {

            let item = folder.children?.object(at: index + 1) as? BookmarkItemManagedObject
            return item?.uuid
        }
        return nil
    }

}

extension BookmarksManager {

    func updateSavedSiteItem(_ item: SavedSiteItem) async {
        if let bookmark = await coreDataStorage.bookmarkWithUUID(item.id) {

            // TODO

        } else {
            guard let url = item.url.punycodedUrl else { return }

            if item.isFavorite {
                _ = try? await coreDataStorage.saveNewFavorite(withTitle: item.title, url: url)
            } else {
                var parentID: NSManagedObjectID?
                if let parentUUID = item.parent {
                    parentID = await coreDataStorage.idForFolderWithUUID(parentUUID)
                }

                _ = try? await coreDataStorage.saveNewBookmark(withTitle: item.title, url: url, parentID: parentID)
            }
        }
    }
    
    func updateSavedSiteFolder(_ folder: SavedSiteFolder) async {
        // TODO update folder
    }
    
    func deleteItemWithUUID(_ uuidString: String) {
        coreDataStorage.deleteItemWithUUID(uuidString)
    }

}

extension BookmarksCoreDataStorage {

    func idForFolderWithUUID(_ uuidString: String) async -> NSManagedObjectID? {
        guard let uuid = UUID(uuidString: uuidString) else { return nil }

        return await withCheckedContinuation { continuation in
            viewContext.perform {
                let fetchRequest: NSFetchRequest<BookmarkFolderManagedObject> = BookmarkFolderManagedObject.fetchRequest()
                fetchRequest.predicate = .matchingUUID(uuid)
                let results = try? self.viewContext.fetch(fetchRequest)
                continuation.resume(returning: results?.first?.objectID)
            }
        }
    }

    func bookmarkWithUUID(_ uuidString: String) async -> BookmarkManagedObject? {
        guard let uuid = UUID(uuidString: uuidString) else { return nil }
        
        return await withCheckedContinuation { continuation in
            viewContext.perform {
                let fetchRequest: NSFetchRequest<BookmarkManagedObject> = BookmarkManagedObject.fetchRequest()
                fetchRequest.predicate = .matchingUUID(uuid)
                let results = try? self.viewContext.fetch(fetchRequest)
                continuation.resume(returning: results?.first)
            }
        }
        
    }
    
    func deleteItemWithUUID(_ uuidString: String) {
        guard let uuid = UUID(uuidString: uuidString) else { return }
                
        viewContext.perform {
            self.deleteBookmarkWithUUID(uuid)
            self.deleteFolderWithUUID(uuid)
            try? self.viewContext.save()
        }
    }
    
    private func deleteFolderWithUUID(_ uuid: UUID) {
        let fetchRequest: NSFetchRequest<BookmarkFolderManagedObject> = BookmarkFolderManagedObject.fetchRequest()
        fetchRequest.predicate = .matchingUUID(uuid)
        self.viewContext.deleteAll(matching: fetchRequest)
    }

    private func deleteBookmarkWithUUID(_ uuid: UUID) {
        let fetchRequest: NSFetchRequest<BookmarkManagedObject> = BookmarkManagedObject.fetchRequest()
        fetchRequest.predicate = .matchingUUID(uuid)
        self.viewContext.deleteAll(matching: fetchRequest)
    }
    
}

extension NSPredicate {
    
    static func matchingUUID(_ uuid: UUID) -> NSPredicate {
        return NSPredicate(format: "uuid == %@", uuid as NSUUID)
    }
    
}
