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

class SavedSiteModel: Identifiable {

    class Bookmark {

        let id: String
        var title: String
        var url: String
        var isFavorite: Bool

        var domain: String {
            URL(string: url)?.host ?? ""
        }

        init(id: String, title: String, url: String, isFavorite: Bool) {
            self.id = id
            self.title = title
            self.url = url
            self.isFavorite = isFavorite
        }

    }

    class Folder {

        let id: String
        var name: String
        var children: [SavedSiteModel]

        init(id: String, name: String, children: [SavedSiteModel]) {
            self.id = id
            self.name = name
            self.children = children
        }

    }

    let id: String
    let bookmark: Bookmark?
    let folder: Folder?

    var label: String {
        bookmark?.title ?? folder?.name ?? ""
    }

    init(id: String, bookmark: Bookmark? = nil, folder: Folder? = nil) {
        self.id = id
        self.bookmark = bookmark
        self.folder = folder
    }

}

extension SavedSiteModel {

    static func bookmark(title: String, url: String, isFavorite: Bool = false) -> SavedSiteModel {
        let id = UUID().uuidString
        return .init(id: id, bookmark: .init(id: id, title: title, url: url, isFavorite: isFavorite))
    }

    static func folder(name: String, children: [SavedSiteModel]) -> SavedSiteModel {
        let id = UUID().uuidString
        return .init(id: id, folder: .init(id: id, name: name, children: children))
    }

}
