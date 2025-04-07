/*
 Copyright 2024 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

#if canImport(SwiftUI)
    import SwiftUI
#endif

import Foundation

/// Settings for customizing the appearance of the ContentCardContainer
@available(iOS 15.0, *)
public struct ContainerSetting {
    /// The spacing between content cards in the container
    public var spacing: CGFloat = 20
    
    public var backgroundColor : Color = Color(.systemBackground)
    
    public var layout: ContainerLayout = .vertical
    
    public var header: ContainerHeader?
    
    public var displayDateTime: Bool = false
    
    public var pullToRefresh: PullToRefreshSettings = PullToRefreshSettings()

    public var unreadState: UnreadState = UnreadState()
    
    public var emptyState: EmptyState = EmptyState()
    
    public var cardHeight: CGFloat? = nil
    
    public var cardWidth: CGFloat? = nil
    
    public init() {}
}

/// Enum defining the possible scroll directions
public enum ContainerLayout {
    case vertical
    case horizontal
}

/// Settings for customizing the container header
@available(iOS 15.0, *)
public struct ContainerHeader {
    
    public var isVisible: Bool = false
    
    public var title: AEPText
    
    public var backgroundColor: Color = Color(.systemBackground)
    
    public var height: CGFloat = 60
    
    public var padding: EdgeInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    
    public init(title: AEPText) {
        self.title = title
    }
}

/// Settings for pull-to-refresh functionality
@available(iOS 15.0, *)
public struct PullToRefreshSettings {
    
    public var isEnabled: Bool = false
    public var tintColor: Color = Color.accentColor
    public var attributedText: AttributedString?
    
    public init() {}
}

@available(iOS 15.0, *)
public struct UnreadState {
    public var isEnabled : Bool = false
    public var backgroundColor : Color?
    
    public var icon : AEPImage?
    public var iconPosition : Alignment = .topLeading
    
    public var barColor : Color = Color.blue
    public var barPosition : Alignment = .leading
    public var barThickness : CGFloat?
}


@available(iOS 15.0, *)
public struct EmptyState {
    public var message = AEPText(content: "no content")
    public var image: AEPImage?
}

