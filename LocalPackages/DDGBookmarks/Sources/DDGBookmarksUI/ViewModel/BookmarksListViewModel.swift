//
//  BookmarksListViewModel.swift
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

class BookmarksListViewModel: ObservableObject {

    static let dummyData = [
        SavedSiteItemWrapper(id: UUID(), item: .bookmark(title: "Title", url: "URL", isFavorite: false)),
        SavedSiteItemWrapper(id: UUID(), item: .bookmark(title: "Title", url: "URL", isFavorite: false)),
        SavedSiteItemWrapper(id: UUID(), item: .folder(childrenCount: 4)),
        SavedSiteItemWrapper(id: UUID(), item: .bookmark(title: "Title", url: "URL", isFavorite: false))
    ]

    static let dummyData2 = [
        SavedSiteItemWrapper(id: UUID(), item: .bookmark(title: "Title", url: "URL", isFavorite: false)),
        SavedSiteItemWrapper(id: UUID(), item: .bookmark(title: "Title", url: "URL", isFavorite: false)),
        SavedSiteItemWrapper(id: UUID(), item: .folder(childrenCount: 0)),
        SavedSiteItemWrapper(id: UUID(), item: .bookmark(title: "Title", url: "URL", isFavorite: false))
    ]

    @Published var items: [SavedSiteItemWrapper] = BookmarksListViewModel.dummyData

    func select(_ item: SavedSiteItemWrapper, isEditing: Bool) {

        print("***", #function, item, isEditing)

        switch item.item {
        case .folder:
            openFolderWithId(item.id)

        case .navigateUp:
            navigateUp()

        case .bookmark:
            openBookmarkWithId(item.id, isEditing: true)

        }

    }

    private func navigateUp() {
        guard !items.isEmpty,
              case .navigateUp = items[0].item else { return }
        items = Self.dummyData
    }

    private func openFolderWithId(_ id: UUID) {
        items = [
            .init(id: UUID(), item: .navigateUp)
        ] + Self.dummyData2
    }

    private func openBookmarkWithId(_ id: UUID, isEditing: Bool) {
    }

}
