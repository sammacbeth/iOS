//
//  FavoritesView.swift
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
import UniformTypeIdentifiers

// https://stackoverflow.com/questions/62606907/swiftui-using-ondrag-and-ondrop-to-reorder-items-within-one-single-lazygrid

// MARK: - Model

class Model: ObservableObject {

    static let size = 64.0 + 16.0

    @Published var data: [SavedSiteModel]

    init() {
        var data = [SavedSiteModel]()
        for i in 0 ..< 20 {
            data.append(.bookmark(title: "Example \(i)", url: "https://www.twitter.com"))
        }
        self.data = data
    }

    func columnsForWidth(_ width: CGFloat) -> [GridItem] {
        return Array(repeating: GridItem(.fixed(Self.size)), count: Int(width / Self.size))
    }

    func delete(_ id: UUID) {
        data = data.filter {
            $0.id != id
        }
    }

}

// MARK: - Grid

struct FavoritesView: View {

    struct OnDragModifier: ViewModifier {

        let d: SavedSiteModel

        @Binding var dragging: SavedSiteModel?

        func body(content: Content) -> some View {

            if #available(iOS 15, macOS 12, *) {

                content.onDrag {
                    self.dragging = d
                    return NSItemProvider(object: d.id.uuidString as NSString)
                } preview: {
                    GridItemView(d: d, isDragging: true, isEditing: false) { }
                }

            } else {

                content.onDrag {
                    self.dragging = d
                    return NSItemProvider(object: d.id.uuidString as NSString)
                }

            }
        }

    }

    @StateObject private var model = Model()

    @State private var dragging: SavedSiteModel?
    @State private var isEditing = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVGrid(columns: model.columnsForWidth(geometry.size.width), spacing: 8) {
                    ForEach(model.data) { d in
                        GridItemView(d: d, isDragging: false, isEditing: isEditing) {
                            model.delete(d.id)
                        }
                        .modifier(OnDragModifier(d: d, dragging: $dragging))
                        .overlay(dragging?.id == d.id ? Color.white.opacity(0.8) : Color.clear)
                        .onDrop(of: [UTType.text], delegate: DragRelocateDelegate(item: d, listData: $model.data, current: $dragging))
                    }
                }
                .animation(.default, value: model.data)
                .padding(.top)
            }
            .background(Color.listBackground)
            .toolbar {

#if os(iOS)
let placement: ToolbarItemPlacement = .bottomBar
#elseif os(macOS)
let placement: ToolbarItemPlacement = .automatic
#endif

                ToolbarItem(placement: placement) {
                    HStack {
                        Spacer()

                        Button("Manage") {
                            withAnimation {
                                isEditing = true
                            }
                        }.visibility(isEditing ? .gone : .visible)

                        Button("Done") {
                            withAnimation {
                                isEditing = false
                            }
                        }.visibility(isEditing ? .visible : .gone)

                        Spacer()
                    }
                }
            }
        }
    }
}

struct DragRelocateDelegate: DropDelegate {
    let item: SavedSiteModel
    @Binding var listData: [SavedSiteModel]
    @Binding var current: SavedSiteModel?

    func dropEntered(info: DropInfo) {
        if item != current {
            let from = listData.firstIndex(of: current!)!
            let to = listData.firstIndex(of: item)!
            if listData[to].id != current!.id {
                listData.move(fromOffsets: IndexSet(integer: from),
                    toOffset: to > from ? to + 1 : to)
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        self.current = nil
        return true
    }
}

// MARK: - GridItem

struct GridItemView: View {

    let d: SavedSiteModel
    let isDragging: Bool
    let isEditing: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack {

            ZStack(alignment: .topTrailing) {

                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 64, height: 64)
                    .foregroundColor(.green)

                Button {
                    onDelete()
                } label: {
                    Image("RemoveFavoriteManageAction", bundle: .module)
                        .foregroundColor(.black)
                        .background(Circle()
                            .foregroundColor(.gray40)
                            .frame(width: 24, height: 24))
                        .offset(x: 8, y: -8)
                }
                .visibility(isDragging || !isEditing ? .gone : .visible)

            }

            Text(d.label)
                .font(.caption)
                .visibility(isDragging ? .gone : .visible)

        }
        .background(Color.clear)
        .frame(width: isDragging ? 64 : 80,
               height: isDragging ? 64 : 102)

    }
}
