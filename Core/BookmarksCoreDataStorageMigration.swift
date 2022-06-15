//
//  BookmarksCoreDataStorageMigration.swift
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
import CoreData

public class BookmarksCoreDataStorageMigration {
    
    @UserDefaultsWrapper(key: .bookmarksMigratedFromUserDefaultsToCD, defaultValue: false)
    private static var migratedFromUserDefaults: Bool
    
    /// Migrates bookmark data to Core Data.
    ///
    /// - Returns: A boolean representing whether the migration took place. If the migration has already happened and this function is called, it returns `false`.
    public static func migrate(fromBookmarkStore bookmarkStore: BookmarkStore, context: NSManagedObjectContext) -> Bool {
        if migratedFromUserDefaults {
            return false
        }
        
        context.performAndWait {
            let countRequest = NSFetchRequest<BookmarkFolderManagedObject>(entityName: BookmarksCoreDataStorage.Constants.folderClassName)
            countRequest.fetchLimit = 1
            let result = (try? context.count(for: countRequest)) ?? 0
            
            guard result == 0 else {
                // Already migrated
                return
            }
            
            let favoritesFolder = BookmarksCoreDataStorage.rootFavoritesFolderManagedObject(context)
            let bookmarksFolder = BookmarksCoreDataStorage.rootFolderManagedObject(context)
            
            func migrateLink(_ link: Link, isFavorite: Bool) {
                let managedObject = NSEntityDescription.insertNewObject(
                    forEntityName: BookmarksCoreDataStorage.Constants.bookmarkClassName,
                    into: context)
                guard let bookmark = managedObject as? BookmarkManagedObject else {
                    assertionFailure("Inserting new bookmark failed")
                    return
                }
                bookmark.url = link.url
                bookmark.title = link.title
                bookmark.isFavorite = isFavorite
                
                let folder = isFavorite ? favoritesFolder : bookmarksFolder
                bookmark.parent = folder
            }
            
            let favorites = bookmarkStore.favorites
            for favorite in favorites {
                migrateLink(favorite, isFavorite: true)
            }
            
            let bookmarks = bookmarkStore.bookmarks
            for bookmark in bookmarks {
                migrateLink(bookmark, isFavorite: false)
            }
                        
            do {
                try context.save()
            } catch {
                fatalError("Error creating top level bookmark folders")
            }
            
            bookmarkStore.deleteAllData()
        }

        migratedFromUserDefaults = true
        return true
    }
}
