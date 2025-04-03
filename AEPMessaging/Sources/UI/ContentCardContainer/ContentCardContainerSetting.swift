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
public struct ContentCardContainerSetting {
    /// The spacing between content cards in the container
    public var spacing: CGFloat = 20
    
    public var backgroundColor : Color = Color(.systemBackground)
    
    /// The scroll direction of the container
    public var scrollDirection: ScrollDirection = .vertical
    
    /// Settings for the container header
    public var header: HeaderSettings?
    
    /// Settings for displaying date and time
    public var displayDateTime: Bool = false
    
    /// Settings for pull-to-refresh functionality
    public var pullToRefresh: PullToRefreshSettings = PullToRefreshSettings()
    
    /// Initializes a new ContentCardContainerSetting instance
    public init() {}
}


/// Enum defining the possible scroll directions
public enum ScrollDirection {
    case vertical
    case horizontal
}

/// Settings for customizing the container header
@available(iOS 15.0, *)
public struct HeaderSettings {
    /// Whether the header is visible
    public var isVisible: Bool = false
    
    /// The title text configuration for the header
    public var title: AEPText
    
    /// The background color for the header
    public var backgroundColor: Color = Color(.systemBackground)
    
    /// The height of the header
    public var height: CGFloat = 60
    
    /// The padding for the header content
    public var padding: EdgeInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    
    /// Initializes a new HeaderSettings instance with the required title
    /// - Parameter title: The AEPText instance for the header title
    public init(title: AEPText) {
        self.title = title
    }
}

/// Settings for pull-to-refresh functionality
@available(iOS 15.0, *)
public struct PullToRefreshSettings {
    /// Whether pull-to-refresh is enabled
    public var isEnabled: Bool = false
    
    /// The tint color for the refresh control
    public var tintColor: Color = Color.accentColor
    
    /// The background color for the refresh control
    public var backgroundColor: Color = Color.clear
    
    /// The attributed text to display during refresh
    public var attributedText: AttributedString?
    
    public init() {}
}
