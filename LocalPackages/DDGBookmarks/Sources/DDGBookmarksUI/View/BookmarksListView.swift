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

    @ObservedObject var model: BookmarksListViewModel

    var onDelete: (SavedSiteItemWrapper) -> Void
    var onToggleFavorite: (SavedSiteItemWrapper) -> Void

    @Environment(\.presentationMode) private var presentationMode

    @Environment(\.editMode) private var editMode
    var isEditing: Bool {
        if case .inactive = editMode?.wrappedValue {
            return false
        }
        return true
    }

    @State var isTapped = false {
        didSet {
            print("*** isTapped", isTapped)
        }
    }

    var body: some View {

        List {

            ForEach(model.items) { item in

                Group {
                    if isEditing {

                        HStack {
                            Text(item.name)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            print("*** onTapGesture", item.name)
                        }

                    } else if item.children != nil {

                        NavigationLink(item.name) {
                            BookmarksListView(model: .init(items: item.children ?? []),
                                              onDelete: onDelete,
                                              onToggleFavorite: onToggleFavorite)
                        }

                    } else {

                        Button {
                            print("*** button action", item.name)
                        } label: {
                            HStack {
                                Text(item.name)
                                Spacer()
                            }
                        }

                    }
                }
                .foregroundColor(Color.listTextColor)
                .modifier(SwipeToDeleteModifier(action: {
                    print("*** swipe to delete")
                }))
                .modifier(SwipeToFavoriteModifier(action: {
                    print("*** swipe to favorite")
                }))

            }
            .onDelete { indexes in
                print("*** onDelete", indexes)
            }
            .onMove { indexes, offset in
                print("*** onMove", indexes, offset)
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
                        }.visibility(model.canImportExport ? .visible : .invisible)
                    }.frame(maxWidth: .infinity)
                }
            } // ToolbarItem
        }
    }

}
