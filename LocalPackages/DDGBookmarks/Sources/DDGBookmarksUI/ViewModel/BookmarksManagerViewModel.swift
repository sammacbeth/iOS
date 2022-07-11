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

    @Published var listViewModel = BookmarksListViewModel(items: [

        .bookmark(title: "Twitter", url: "https://www.twitter.com"),
        .folder(name: "TV", children: [
            .bookmark(title: "Netflix", url: "https://netflix.com"),
            .bookmark(title: "Amazon Prime", url: "https://prime.amazon.com"),
            .folder(name: "IMDB", children: [
                .bookmark(title: "Stranger Things", url: "https://www.imdb.com/title/tt4574334/?ref_=fn_al_tt_1"),
                .bookmark(title: "For All Mankind", url: "https://www.imdb.com/title/tt7772588/?ref_=fn_al_tt_1")
            ])
        ]),
        .folder(name: "Music", children: [
            .bookmark(title: "Apple Music", url: "https://music.apple.com"),
            .bookmark(title: "Spotify", url: "https://spotify.com")
        ])
    ])

    public init() { }

    func delete(_ model: SavedSiteModel) {
        print("***", #function, model)
    }

    func toggleFavorite(_ model: SavedSiteModel) {
        print("***", #function, model)
    }

}
