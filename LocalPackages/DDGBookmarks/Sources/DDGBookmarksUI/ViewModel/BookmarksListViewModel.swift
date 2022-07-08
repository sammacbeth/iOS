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

    @Published var items: [SavedSiteItemWrapper]
    @Published var canImportExport = true

    init() {
        items = [
           SavedSiteItemWrapper(id: UUID(), name: "Name 1", url: "url", children: nil),
           SavedSiteItemWrapper(id: UUID(), name: "Name 2", url: "url", children: nil),
           SavedSiteItemWrapper(id: UUID(), name: "Name 3", url: "url", children: nil),
           SavedSiteItemWrapper(id: UUID(), name: "Folder 4", url: "url", children: [
               SavedSiteItemWrapper(id: UUID(), name: "Folder 4.1", url: "url", children: [
                   SavedSiteItemWrapper(id: UUID(), name: "Name 4.1.1", url: "url", children: nil),
                   SavedSiteItemWrapper(id: UUID(), name: "Name 4.1.2", url: "url", children: nil),
                   SavedSiteItemWrapper(id: UUID(), name: "Name 4.1.3", url: "url", children: nil)
               ]),
               SavedSiteItemWrapper(id: UUID(), name: "Name 4.2", url: "url", children: nil),
               SavedSiteItemWrapper(id: UUID(), name: "Name 4.3", url: "url", children: nil),
               SavedSiteItemWrapper(id: UUID(), name: "Name 4.4", url: "url", children: [
                   SavedSiteItemWrapper(id: UUID(), name: "Name 4.4.1", url: "url", children: nil),
                   SavedSiteItemWrapper(id: UUID(), name: "Name 4.4.2", url: "url", children: nil),
                   SavedSiteItemWrapper(id: UUID(), name: "Name 4.4.3", url: "url", children: nil)
               ]),
               SavedSiteItemWrapper(id: UUID(), name: "Name 4.5", url: "url", children: nil)
           ])
       ]
    }

    init(items: [SavedSiteItemWrapper], canImportExport: Bool = true) {
        print("*** init", items.count, items[0].id)
        self.items = items
        self.canImportExport = canImportExport
    }

}
