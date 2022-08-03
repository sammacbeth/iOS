//
//  PrivacyIconLogic.swift
//  DuckDuckGo
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
import Core

final class PrivacyIconLogic {
    
    static func privacyIcon(for url: URL?) -> PrivacyIcon {
        if let url = url, AppUrls().isDuckDuckGoSearch(url: url) {
            return .daxLogo
        } else {
            return .shield
        }
    }
    
    static func privacyIcon(for siteRating: SiteRating, in animationState: TrackersAnimationState) -> PrivacyIcon {
        
        if TrackerAnimationLogic.shouldAnimateTrackers(for: siteRating) && animationState == .beforeAnimations {
            return .shield
        } else {
            return privacyIcon(for: siteRating)
        }
    }
    
    static func privacyIcon(for siteRating: SiteRating) -> PrivacyIcon {
        if AppUrls().isDuckDuckGoSearch(url: siteRating.url) {
            return .daxLogo
        } else {
            let config = ContentBlocking.privacyConfigurationManager.privacyConfig
            let isUserUnprotected = config.isUserUnprotected(domain: siteRating.url.host)
 
            let notFullyProtected = !siteRating.https || siteRating.isMajorTrackerNetwork || isUserUnprotected
            
            return notFullyProtected ? .shieldWithDot : .shield
        }
    }
}
