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

    @EnvironmentObject var model: BookmarksManagerViewModel

    enum Segments: Int {
        case allBookmarks, favorites
    }

    public init() { }

    @State private var selectedViewIndex = Segments.allBookmarks

    @Environment(\.editMode) private var editMode
    var isEditing: Bool {
        if case .inactive = editMode?.wrappedValue {
            return false
        }
        return true
    }

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
                        BookmarksListView(model: model.listViewModel,
                                          title: "Bookmarks",
                                          onDelete: model.delete,
                                          onToggleFavorite: model.toggleFavorite)

                    case .favorites:
                        FavoritesView()
                    }
                }
                .padding(.top, 19)
                .navigationTitle("Bookmarks")
                .navigationBarHidden(false)
                .navigationBarTitleDisplayMode(.inline)

                Spacer()

            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        print("Done")
                        presentationMode.wrappedValue.dismiss()
                    }
                } // ToolbarItem
            }

        }
        .navigationViewStyle(.stack)

    }

}
