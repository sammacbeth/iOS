//
//  BookmarksManagerViewModel.swift
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

public class BookmarksManagerViewModel: ObservableObject {

    struct Folders {

        static let tv = UUID()
        static let imdb = UUID()
        static let music = UUID()

    }

    @Published var listViewModel = BookmarksListViewModel(items: [])

    public init() {
        listViewModel.items = [
            .bookmark(title: "Twitter", url: "https://www.twitter.com"),
            .folder(id: Folders.tv, name: "TV", childrenCount: 3),
            .folder(id: Folders.music, name: "🎼 Music 🎶", childrenCount: 2)
        ]
    }

    func delete(_ model: SavedSiteModel) {
        print("***", #function, model)
    }

    func toggleFavorite(_ model: SavedSiteModel) {
        print("***", #function, model)
    }

    func childrenForFolderWithUUID(_ id: UUID) -> [SavedSiteModel]? {

        switch id {
        case Folders.tv:
            return [
                .bookmark(title: "Netflix", url: "https://netflix.com"),
                .bookmark(title: "Amazon Prime", url: "https://prime.amazon.com"),
                .bookmark(title: "Disney+", url: "https://disneyplus.com"),
                .folder(id: Folders.imdb, name: "IMDB", childrenCount: 2)
            ]

        case Folders.imdb:
            return [
                .bookmark(title: "Stranger Things", url: "https://www.imdb.com/title/tt4574334/?ref_=fn_al_tt_1"),
                .bookmark(title: "For All Mankind", url: "https://www.imdb.com/title/tt7772588/?ref_=fn_al_tt_1")
            ]

        case Folders.music:
            return [
                .bookmark(title: "Apple Music", url: "https://music.apple.com"),
                .bookmark(title: "Spotify", url: "https://spotify.com")
            ]

        default:
            return nil
        }

    }

}
