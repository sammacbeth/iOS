//
//  DuckSwiftUI.swift
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

extension Font {

    private enum Name {
        static let proximaNovaRegular = "ProximaNova-Regular"
        static let proximaNovaLight = "ProximaNova-Light"
        static let proximaNovaSemibold = "ProximaNova-Semibold"
        static let proximaNovaBold = "ProximaNova-Bold"
    }

    public static func appFont(ofSize size: CGFloat) -> Font {
        return .custom(Name.proximaNovaRegular, size: size)
    }

    public static func lightAppFont(ofSize size: CGFloat) -> Font {
        return .custom(Name.proximaNovaLight, size: size)
    }

    public static func semiBoldAppFont(ofSize size: CGFloat) -> Font {
        return .custom(Name.proximaNovaSemibold, size: size)
    }

    public static func boldAppFont(ofSize size: CGFloat) -> Font {
        return .custom(Name.proximaNovaBold, size: size)
    }

}

// https://swiftuirecipes.com/blog/how-to-hide-a-swiftui-view-visible-invisible-gone
enum ViewVisibility: CaseIterable {

    case visible, // view is fully visible
         invisible, // view is hidden but takes up space
         gone // view is fully removed from the view hierarchy

}

extension View {

    // https://swiftuirecipes.com/blog/how-to-hide-a-swiftui-view-visible-invisible-gone
    @ViewBuilder func visibility(_ visibility: ViewVisibility) -> some View {
        if visibility != .gone {
            if visibility == .visible {
                self
            } else {
                hidden()
            }
        }
    }

    func link(onHoverChanged: ((Bool) -> Void)? = nil, clicked: @escaping () -> Void) -> some View {
        self.onHover { over in
            onHoverChanged?(over)
        }.onTapGesture {
            clicked()
        }
    }

}
