//
//  BookmarksListView.swift
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

struct BookmarksListView: View {

    @Environment(\.editMode) private var editMode
    @ObservedObject var model: BookmarksListViewModel

    var onDelete: (SavedSiteItemWrapper) -> Void
    var onToggleFavorite: (SavedSiteItemWrapper) -> Void

    var isEditing: Bool {
        if case .inactive = editMode?.wrappedValue {
            return false
        }
        return true
    }

    var body: some View {
        List {

            ForEach(model.items, id: \.id) { site in

                SavedSiteListItemView(site: site) {
                    model.select(site, isEditing: isEditing)
                } onToggleFavorite: {
                    onToggleFavorite(site)
                } onDelete: {
                    onDelete(site)
                }

            }
            .onDelete { indexSet in
                print(indexSet)
            }
            .onMove { indexSet, index in
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
                        // We want custom behaviours otherwise we could just use SwiftUI's EditButton
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
                        Menu {
                            Button {
                                print("*** Import")
                            } label: {
                                Text("Import")
                            }
                            Button {
                                print("*** Export")
                            } label: {
                                Text("Export")
                            }
                        } label: {
                            Text("More")
                        }
                    }.frame(maxWidth: .infinity)
                }
            }
        }
    }

}

struct SavedSiteListItemView: View {

    struct SwipeToFavoriteModifier: ViewModifier {

        var action: () -> Void

        func body(content: Content) -> some View {
            if #available(iOS 15, *) {
                content.swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        action()
                    } label: {
                        HStack {
                            Image("Star-16", bundle: Bundle.module)
                                .foregroundColor(Color.black)
                            Text("Add Favorite")
                        }
                    }.tint(.yellow)
                }
            }
        }

    }

    struct SwipeToDeleteModifier: ViewModifier {

        var action: () -> Void

        func body(content: Content) -> some View {
            if #available(iOS 15, *) {
                content.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        action()
                    } label: {
                        Text("Delete")
                    }
                }
            }
        }
    }

    let site: SavedSiteItemWrapper
    let onTapGesture: () -> Void
    let onToggleFavorite: () -> Void
    let onDelete: () -> Void

    @State var bgColor: Color = .clear

    var body: some View {
        Group {
            switch site.item {
            case .bookmark(let title, let url, let isFavorite):
                HStack {
                    Text("Bookmark(\(title), \(url), \(isFavorite.description))")
                        .modifier(SwipeToFavoriteModifier {
                            onToggleFavorite()
                        })
                        .modifier(SwipeToDeleteModifier {
                            onDelete()
                        })
                    Spacer()
                }

            case .folder(let count):
                HStack {
                    Text("Folder(\(count))")
                        .modifier(SwipeToDeleteModifier {
                            onDelete()
                        })
                    Spacer()
                    Image(systemName: "chevron.right")
                }

            case .navigateUp:
                HStack {
                    Text("Navigate Up")
                    Spacer()
                    Image(systemName: "chevron.up")
                }
            }

        }
        .contentShape(
            Rectangle()
        )
        .onTapGesture {
            onTapGesture()
        }
    }

}
