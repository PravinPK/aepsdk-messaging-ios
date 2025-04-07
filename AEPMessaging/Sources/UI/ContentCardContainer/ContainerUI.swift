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
    import Combine
#endif

import AEPServices
import Foundation

/// ContentCardUI is a class that holds data for a content card and provides a SwiftUI view representation of that content.
@available(iOS 15.0, *)
public class ContainerUI: Identifiable, ObservableObject {
    /// The underlying data model for the content card.
    @Published private(set) var contentCards: [ContentCardUI] = []
    
    /// Settings for customizing the container appearance
    @Published public var settings: ContainerSetting
    
    /// Current state of the container
    @Published public private(set) var state: ContainerState = .downloading
    
    /// The surface for which this container is created
    private let surface: Surface
    
    /// Customizer for content cards
    private let customizer: ContentCardCustomizing?
    
    /// Listener for content card events
    private let listener: ContentCardUIEventListening?
    
    /// SwiftUI view that represents the content card
    public var view: some View {
        ContainerStateView(container: self)
    }
    
    /// Initializes a new `ContainerUI` instance
    /// - Parameters:
    ///   - surface: The surface for which to retrieve the content cards
    ///   - customizer: Optional customizer for content cards
    ///   - listener: Optional listener for content card events
    ///   - settings: Optional settings to customize the container appearance
    init(surface: Surface,
         customizer: ContentCardCustomizing? = nil,
         listener: ContentCardUIEventListening? = nil,
         settings: ContainerSetting = ContainerSetting()) {
        self.surface = surface
        self.customizer = customizer
        self.listener = listener
        self.settings = settings
        
        // Start downloading immediately
        downloadCards()
    }
    
    /// Refreshes the settings and redraws the view
    /// - Parameter newSettings: The new settings to apply
    public func refreshSettings(_ newSettings: ContainerSetting) {
        self.settings = newSettings
        applyUnreadSettings()
    }
    
    /// Downloads the content cards for the surface
    public func downloadCards() {
        state = .downloading
        Messaging.getPropositionsForSurfaces([surface]) { [weak self] propositionDict, error in
            guard let self = self else { return }
            
            // Using DispatchQueue.main to ensure UI updates happen on the main thread
            DispatchQueue.main.async {
                if let error = error {
                    Log.error(label: UIConstants.LOG_TAG,
                             "Error retrieving content cards UI for surface, \(self.surface.uri). Error \(error)")
                    self.state = .error(error)
                    return
                }

                var cards: [ContentCardUI] = []

                guard let propositions = propositionDict?[self.surface] else {
                    self.state = .empty
                    self.contentCards = []
                    return
                }

                for proposition in propositions {
                    guard let contentCard = ContentCardUI.createInstance(with: proposition,
                                                                      customizer: self.customizer,
                                                                      listener: self.listener) else {
                        Log.warning(label: UIConstants.LOG_TAG,
                                 "Failed to create ContentCardUI for proposition with ID: \(proposition.uniqueId)")
                        continue
                    }
                    cards.append(contentCard)
                }
                
                self.contentCards = cards
                self.applyUnreadSettings()
                self.state = .loaded
            }
        }
    }
    
    private func applyUnreadSettings() {
        let unreadState = settings.unreadState
        if unreadState.isEnabled {
            for card in contentCards {
                if ((card.meta?["unread"]) != nil) {
                    if let unreadBackground = settings.unreadState.backgroundColor {
                        card.template.backgroundColor = unreadBackground
                    }
                    if let unreadIcon = settings.unreadState.icon {
                        card.template.addOverlay(unreadIcon.view.padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 0)), alignment: settings.unreadState.iconPosition)
                    }
                    if let barThickness = settings.unreadState.barThickness {
                        switch settings.unreadState.barPosition {
                        case .top:
                            card.template.addOverlay(Rectangle().fill(settings.unreadState.barColor).frame(width: nil, height: barThickness), alignment: .top)
                        case .bottom:
                            card.template.addOverlay(Rectangle().fill(settings.unreadState.barColor).frame(width: nil, height: barThickness), alignment: .bottom)
                        case .leading:
                            card.template.addOverlay(Rectangle().fill(settings.unreadState.barColor).frame(width: barThickness, height: nil), alignment: .leading)
                        case .trailing:
                            card.template.addOverlay(Rectangle().fill(settings.unreadState.barColor).frame(width: barThickness, height: nil), alignment: .trailing)
                        default:
                            // Default to leading if an unsupported alignment is provided
                            card.template.addOverlay(Rectangle().fill(settings.unreadState.barColor).frame(width: barThickness, height: nil), alignment: .leading)
                        }
                    }
                }
            }
        }
    }
    
    func buildContainerView() -> some View {
        VStack(spacing: 0) {
            if let header = settings.header, header.isVisible {
                headerView(header)
            }
            buildScrollView()
        }
    }

    @ViewBuilder
    func buildScrollView() -> some View {
        let scrollDirection: Axis.Set = settings.layout == .vertical ? .vertical : .horizontal
        
        let scrollView = ScrollView(scrollDirection, showsIndicators: false) {
            Group {
                contentForCurrentState()
            }
        }
        .background(settings.backgroundColor)
        
        if settings.pullToRefresh.isEnabled {
            scrollView
                .refreshable {
                    self.downloadCards()
                }
        } else {
            scrollView
        }
    }
    
    @ViewBuilder
    func contentForCurrentState() -> some View {
        switch state {
        case .downloading:
            AnyView(ProgressView())
        case .empty:
            AnyView(settings.emptyState.message.view)
        case .error(let error):
            AnyView(Text("Error: \(error.localizedDescription)").foregroundColor(.red))
        case .loaded:
            if settings.layout == .vertical {
                LazyVStack(spacing: settings.spacing) {
                    cardView
                }
            } else {
                LazyHStack(spacing: settings.spacing) {
                    cardView
                }
            }
        }
    }
    
    var cardView: some View {
        ForEach(contentCards) { card in
            card.view
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
                .padding()
        }
    }
    
    private func headerView(_ header: ContainerHeader) -> some View {
        VStack {
            header.title.view
                .frame(maxWidth: .infinity)
        }
        .frame(height: header.height)
        .padding(header.padding)
        .background(header.backgroundColor)
    }
}

/// A wrapper view that observes changes to the container
@available(iOS 15.0, *)
private struct ContainerStateView: View {
    @ObservedObject var container: ContainerUI
    
    var body: some View {
        container.buildContainerView()
    }
}

/// Represents the current state of the container
@available(iOS 15.0, *)
public enum ContainerState {
    case downloading
    case loaded
    case empty
    case error(Error)
}

@available(iOS 15.0, *)
struct UnreadModifier : ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(
            Text("NEW").foregroundStyle(.red) .padding(EdgeInsets(top: 20, leading: 30, bottom: 0, trailing: 0)), alignment: .topLeading
        )
    }
}
