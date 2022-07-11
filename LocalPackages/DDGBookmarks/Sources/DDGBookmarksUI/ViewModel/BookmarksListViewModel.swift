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

    let id = UUID()

    @Published var items: [SavedSiteModel]
    @Published var canImportExport = true
    @Published var editingItem: SavedSiteModel?
    @Published var showingEditor = false {
        didSet {
            print("***", id, Self.self, #function, showingEditor)
        }
    }

    init(items: [SavedSiteModel], canImportExport: Bool = true) {
        self.items = items
        self.canImportExport = canImportExport
        print("***", id, Self.self, #function)
    }

    func edit(_ item: SavedSiteModel) {
        editingItem = item
        showingEditor = true
    }

    deinit {
        print("***", id, Self.self, #function)
    }

}
