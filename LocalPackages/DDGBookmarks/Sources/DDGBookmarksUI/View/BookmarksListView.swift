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

        let isFavorite: Bool

        var action: () -> Void

        func body(content: Content) -> some View {
            if #available(iOS 15, macOS 12, *) {
                content.swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        action()
                    } label: {
                        Label {
                            Text("Favorite")
                        } icon: {
                            Image("FavoriteAction", bundle: Bundle.module)
                        }.visibility(isFavorite ? .visible : .gone)

                        Label {
                            Text("Remove Favorite")
                        } icon: {
                            Image("RemoveFavoriteAction", bundle: Bundle.module)
                        }.visibility(isFavorite ? .gone : .visible)
                    }
                    .tint(.favoriteAction)
                }
            }
        }

    }

    struct SwipeToDeleteModifier: ViewModifier {

        var action: () -> Void

        func body(content: Content) -> some View {
            if #available(iOS 15, macOS 12, *) {
                content.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        action()
                    } label: {
                        Label {
                            Text("Delete")
                        } icon: {
                            Image("DeleteAction", bundle: Bundle.module)
                        }
                    }
                }
            }
        }
    }

    @ObservedObject var model: BookmarksListViewModel
    let title: String
    var onDelete: (SavedSiteModel) -> Void
    var onToggleFavorite: (SavedSiteModel) -> Void

    @Environment(\.presentationMode) private var presentationMode

    #if os(iOS)
    @Environment(\.editMode) private var editMode
    var isEditing: Bool {
        if case .active = editMode?.wrappedValue {
            return true
        }
        return false
    }
    #elseif os(macOS)
    var isEditing = false
    #endif

    func editItem(_ item: SavedSiteModel) {
        #if os(iOS)
        editMode?.wrappedValue = .inactive
        #endif
        model.edit(item)
    }

    var body: some View {

        List {

            ForEach(model.items) { item in

                Group {

                    if let bookmark = item.bookmark {

                        BookmarkCellView(bookmark: bookmark, isEditing: isEditing) {
                            print("*** Bookmark tapped")
                        } edit: {
                            editItem(item)
                        }
                        .modifier(SwipeToFavoriteModifier(isFavorite: bookmark.isFavorite, action: {
                            print("*** swipe to favorite")
                        }))
                        .modifier(SwipeToDeleteModifier(action: {
                            print("*** swipe to delete")
                        }))

                    } else if let folder = item.folder {

                        FolderCellView(folder: folder, isEditing: isEditing, onDelete: onDelete, onToggleFavorite: onToggleFavorite) {
                            editItem(item)
                        }
                        .modifier(SwipeToDeleteModifier(action: {
                            print("*** swipe to delete")
                        }))

                    } else {

                        fatalError("Unexpected saved site item")

                    }

                }
                .foregroundColor(.listText)

            }
            .onDelete { indexes in
                print("*** onDelete", indexes)
            }
            .onMove { indexes, offset in
                print("*** onMove", indexes, offset)
            }

        }
        .sheet(isPresented: $model.showingEditor) {
            Text("Editor for \(model.editingItem?.id.uuidString ?? "<nil>")")
        }
        .navigationTitle(title)
        #if os(iOS)
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {

            #if os(iOS)
            let placement: ToolbarItemPlacement = .bottomBar
            #elseif os(macOS)
            let placement: ToolbarItemPlacement = .automatic
            #endif

            ToolbarItem(placement: placement) {
                HStack {
                    HStack {
                        Button("Add Folder") {
                            print("*** Add Folder")
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)

                    #if os(iOS)
                    // SwiftUI EditButton uses an animation which makes the UI go screwy
                    HStack {
                        Spacer()

                        Button("Edit") {
                            print("*** Edit")
                            editMode?.wrappedValue = .active
                        }.visibility(editMode?.wrappedValue == .inactive ? .visible : .gone)

                        Button("Done") {
                            print("*** Done")
                            editMode?.wrappedValue = .inactive
                        }.visibility(editMode?.wrappedValue == .active ? .visible : .gone)

                        Spacer()
                            .visibility(isEditing ? .gone : .visible)
                    }
                    .frame(maxWidth: .infinity)
                    #endif

                    HStack {
                        Spacer()

                        Menu {
                            Button {
                                print("*** Export")
                            } label: {
                                Label("Export HTML File", systemImage: "arrow.backward.to.line")
                            }

                            Button {
                                print("*** Import")
                            } label: {
                                Label("Import HTML File", systemImage: "arrow.forward.to.line")
                            }

                            Text("Import an HTML file of bookmarks from another browser, or export your existing bookmarks.")
                                .font(.largeTitle)

                        } label: {
                            Text("More")
                        }.visibility(model.canImportExport ? .visible : .invisible)
                    }
                    .frame(maxWidth: .infinity)
                    .visibility(isEditing ? .gone : .visible)
                }
            } // ToolbarItem
        }
    }

}
