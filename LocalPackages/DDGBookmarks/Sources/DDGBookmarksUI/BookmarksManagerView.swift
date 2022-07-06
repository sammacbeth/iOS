//
//  BookmarksManagerView.swift
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


import SwiftUI
import DuckUI

public struct BookmarksManagerView: View {

    @Environment(\.presentationMode) var presentationMode

    enum Segments: Int {
        case allBookmarks, favorites
    }

    public init() {
    }

    @State private var selectedViewIndex = Segments.allBookmarks

    public var body: some View {
        NavigationView {

            VStack {

                Picker("Bookmarks or Favorites", selection: $selectedViewIndex, content: {
                    Text("All").tag(Segments.allBookmarks)
                    Text("Favorites").tag(Segments.favorites)
                })
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)

                Group {
                    switch selectedViewIndex {
                    case .allBookmarks:
                        BookmarksListView()

                    case .favorites:
                        FavoritesView()
                            .toolbar {
                                ToolbarItem(placement: .bottomBar) {
                                    Text("Favorites")
                                }
                            }
                    }
                }
                .padding(.top, 19)
                .navigationTitle("Bookmarks")
                .navigationBarHidden(false)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }

                Spacer()

            }

        }
        .navigationViewStyle(.stack)

    }

}

struct SavedSiteItemWrapper: Identifiable {

    let id = UUID()
    let item: SavedSiteItem

}

enum SavedSiteItem {

    case bookmark(title: String, url: String, isFavorite: Bool)
    case folder(childrenCount: Int)

}

struct BookmarksListView: View {

    @Environment(\.editMode) private var editMode

    var items: [SavedSiteItemWrapper] = [
        SavedSiteItemWrapper(item: .bookmark(title: "Title", url: "URL", isFavorite: false))
    ]

    @State var searchText = "" {
        didSet {
            print("*** searchText", searchText)
        }
    }

    var body: some View {
        List {

            ForEach(items, id: \.id) { site in

                switch site.item {

                case .bookmark(let title, let url, let isFavorite):
                    Text("Bookmark(\(title), \(url), \(isFavorite.description))")

                case .folder(let count):
                    Text("\(count)")
                }

            }.onDelete { indexSet in
                print(indexSet)
            }.onMove { indexSet, index in
                print(indexSet, index)
            }

        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    ZStack(alignment: .leading) {
                        Button("Add Folder") {
                            print("*** Add Folder")
                        }
                    }.frame(maxWidth: .infinity)
                    ZStack {
                        // We want custom behaviours otherwise we could just use EditButton
                        Button("Edit") {
                            print("*** Edit")
                            editMode?.wrappedValue = .active
                        }.visibility(editMode?.wrappedValue == .inactive ? .visible : .gone)
                        Button("Done") {
                            print("*** Done")
                            editMode?.wrappedValue = .inactive
                        }.visibility(editMode?.wrappedValue == .active ? .visible : .gone)
                    }.frame(maxWidth: .infinity)
                    ZStack(alignment: .trailing) {
                        Button("More") {
                            print("*** More")
                        }
                    }.frame(maxWidth: .infinity)
                }
            }
        }
    }

}

struct FavoritesView: View {

    var body: some View {
        Text("FavoritesView")
    }

}
