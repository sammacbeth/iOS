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

    var onDelete: (SavedSiteModel) -> Void
    var onToggleFavorite: (SavedSiteModel) -> Void

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.editMode) private var editMode

    var isEditing: Bool {
        if case .active = editMode?.wrappedValue {
            return true
        }
        return false
    }

    var body: some View {

        List {

            ForEach(model.items) { item in

                Group {

                    if let bookmark = item.bookmark {

                        BookmarkCellView(bookmark: bookmark, isEditing: isEditing) {
                            print("*** Bookmark tapped")
                        } edit: {
                            model.edit(item)
                        }
                        .modifier(SwipeToFavoriteModifier(action: {
                            print("*** swipe to favorite")
                        }))
                        .modifier(SwipeToDeleteModifier(action: {
                            print("*** swipe to delete")
                        }))

                    } else if let folder = item.folder {

                        FolderCellView(folder: folder, isEditing: isEditing, onDelete: onDelete, onToggleFavorite: onToggleFavorite) {
                            model.edit(item)
                        }
                        .modifier(SwipeToDeleteModifier(action: {
                            print("*** swipe to delete")
                        }))

                    } else {

                        fatalError("Unexpected saved site item")

                    }

                }
                .foregroundColor(Color.listTextColor)

            }
            .onDelete { indexes in
                print("*** onDelete", indexes)
            }
            .onMove { indexes, offset in
                print("*** onMove", indexes, offset)
            }

        }
        .sheet(isPresented: $model.showingEditor) {
            Text("Editor for \(model.editingItem?.id ?? "<nil>")")
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
struct FolderCellView: View {

    let folder: SavedSiteModel.Folder
    let isEditing: Bool
    let onDelete: (SavedSiteModel) -> Void
    let onToggleFavorite: (SavedSiteModel) -> Void
    let edit: () -> Void

    var body: some View {

        let cell = HStack {
            Image(systemName: "folder") // TODO use correct image
            Text(folder.name)
        }

        if isEditing {
            cell
                .modifier(DisclosureModifier())
                .onTapGesture {
                    edit()
                }
        } else {
            NavigationLink {
                BookmarksListView(model: .init(items: folder.children), onDelete: onDelete, onToggleFavorite: onToggleFavorite)
            } label: {
                cell
            }
        }
    }

}

struct BookmarkCellView: View {

    let bookmark: SavedSiteModel.Bookmark
    let isEditing: Bool
    let action: () -> Void
    let edit: () -> Void

    var body: some View {

        let cell = HStack {
            FaviconView(domain: bookmark.domain)
            Text(bookmark.title)
        }

        if isEditing {
            cell
                .modifier(DisclosureModifier())
                .onTapGesture {
                    edit()
                }
        } else {
            Button {
                action()
            } label: {
                cell
            }
        }
    }

}

struct DisclosureModifier: ViewModifier {

    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
            Image(systemName: "chevron.right")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }

}
