//
//  SavedSiteModel.swift
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

class SavedSiteModel: Identifiable, Equatable {

    static func == (lhs: SavedSiteModel, rhs: SavedSiteModel) -> Bool {
        return lhs.id == rhs.id
    }

    class Bookmark {

        let id: UUID
        var title: String
        var url: String
        var isFavorite: Bool

        var domain: String {
            URL(string: url)?.host ?? ""
        }

        init(id: UUID, title: String, url: String, isFavorite: Bool) {
            self.id = id
            self.title = title
            self.url = url
            self.isFavorite = isFavorite
        }

    }

    class Folder {

        let id: UUID
        var name: String
        var childrenCount: Int

        init(id: UUID, name: String, childrenCount: Int) {
            self.id = id
            self.name = name
            self.childrenCount = childrenCount
        }

    }

    let id: UUID
    let bookmark: Bookmark?
    let folder: Folder?

    var label: String {
        bookmark?.title ?? folder?.name ?? ""
    }

    init(id: UUID, bookmark: Bookmark? = nil, folder: Folder? = nil) {
        self.id = id
        self.bookmark = bookmark
        self.folder = folder
    }

}

extension SavedSiteModel {

    static func bookmark(id: UUID = UUID(), title: String, url: String, isFavorite: Bool = false) -> SavedSiteModel {
        return .init(id: id, bookmark: .init(id: id, title: title, url: url, isFavorite: isFavorite))
    }

    static func folder(id: UUID = UUID(), name: String, childrenCount: Int) -> SavedSiteModel {
        return .init(id: id, folder: .init(id: id, name: name, childrenCount: childrenCount))
    }

}
