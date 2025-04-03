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

import AEPServices
import Foundation

/// ContentCardUI is a class that holds data for a content card and provides a SwiftUI view representation of that content.
@available(iOS 15.0, *)
public class ContainerUI: Identifiable {
    /// The underlying data model for the content card.
    let contentCards: [ContentCardUI]
    
    /// Settings for customizing the container appearance
    let settings: ContainerSetting

    /// SwiftUI view that represents the content card
    /// TODO: Make adjustments to remove AnyView
    public lazy var view: some View = buildContainerView()

    /// Initializes a new `ContentCardUI` instance with the given schema data and template.
    /// - Parameters:
    ///   - contentCards: The `ContentCardUI` array containing all the content cards for the surface
    ///   - settings: Optional settings to customize the container appearance
    init(_ contentCards: [ContentCardUI], settings: ContainerSetting = ContainerSetting()) {
        self.contentCards = contentCards
        self.settings = settings
    }
    
    private func buildContainerView() -> some View {
        VStack(spacing: 0) {
            if let header: HeaderSettings = settings.header, header.isVisible {
                headerView(header)
            }
            
            buildScrollView()
        }
    }

    @ViewBuilder
    private func buildScrollView() -> some View {
        let scrollView = ScrollView(settings.scrollDirection == .vertical ? .vertical : .horizontal, showsIndicators: false) {
            Group {
                if settings.scrollDirection == .vertical {
                    LazyVStack(spacing: settings.spacing) {
                        cardView
                    }
                } else {
                    LazyHStack(spacing: settings.spacing) {
                        cardView
                    }
                }
            }
        }.background(settings.backgroundColor)

        if settings.pullToRefresh.isEnabled {
            scrollView
                .refreshable {
                    print("code")
                }
        } else {
            scrollView
        }
    }
    
    private var cardView: some View {
        ForEach(contentCards) { card in
            card.view
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
                .padding()
        }
    }
    
    private func headerView(_ header: HeaderSettings) -> some View {
        VStack {
            header.title.view
                .frame(maxWidth: .infinity)
        }
        .frame(height: header.height)
        .padding(header.padding)
        .background(header.backgroundColor)
    }
}
