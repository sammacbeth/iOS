//
//  Cells.swift
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

struct FolderCellView: View {

    @EnvironmentObject var model: BookmarksManagerViewModel

    let folder: SavedSiteModel.Folder
    let isEditing: Bool
    let onDelete: (SavedSiteModel) -> Void
    let onToggleFavorite: (SavedSiteModel) -> Void
    let edit: () -> Void

    @State var listModel = BookmarksListViewModel(items: [], canImportExport: false)

    @State var selection: String?

    var body: some View {

        let cell = HStack {
            Image(systemName: "folder") // TODO use correct image
            Text(folder.name)
            Spacer()
            Text("\(folder.childrenCount)") // TODO apply style
        }

        if isEditing {
            cell
                .modifier(DisclosureModifier())
                .onTapGesture(perform: edit)
        } else {
            NavigationLink {
                BookmarksListView(model: listModel,
                                  title: folder.name,
                                  onDelete: onDelete,
                                  onToggleFavorite: onToggleFavorite)
                .onAppear {
                    listModel.items = model.childrenForFolderWithUUID(folder.id) ?? []
                }
            } label: {
                cell
            }
            .isDetailLink(false)
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
