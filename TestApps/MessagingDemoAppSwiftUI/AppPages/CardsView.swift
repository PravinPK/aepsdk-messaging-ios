/*
Copyright 2023 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/

import AEPMessaging
import SwiftUI

struct CardsView: View, ContentCardUIEventListening {
    
    let cardsSurface = Surface(path: Constants.SurfaceName.CONTENT_CARD)
    @State var container : ContentCardContainerUI?
    @State private var viewLoaded: Bool = false
    @State private var showLoadingIndicator: Bool = false
    @State private var isHorizontalScroll: Bool = false
    @State private var showHeader: Bool = true
    @State private var isSettingsVisible: Bool = false
    @State private var settingsOffset: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                TabHeader(title: "Content Cards", refreshAction: {
                    refreshCards()
                }, redownloadAction: {
                    downloadCards()
                    refreshCards()
                })
                
                if let containerView = container?.view {
                    containerView
                        .border(Color.red, width: 2)
                }
                
                Spacer()
            }
            
            // Settings Pull Tab when settings are not visible
            if !isSettingsVisible {
                Image(systemName: "chevron.up")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(.systemGray3))
                    .frame(height: 24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(radius: 5)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isSettingsVisible = true
                        }
                    }
                    .padding(.horizontal)
            }
            
            // Settings Panel
            ContainerSettingsView(
                isHorizontalScroll: $isHorizontalScroll,
                showHeader: $showHeader,
                isSettingsVisible: $isSettingsVisible,
                onSettingsChanged: refreshCards
            )
            .padding(.horizontal)
            .offset(y: isSettingsVisible ? 0 : UIScreen.main.bounds.height)
            .animation(.spring(), value: isSettingsVisible)
        }
        .onAppear() {
            if !viewLoaded {
                viewLoaded = true
                refreshCards()
            }
        }
    }
    
    func refreshCards() {
        showLoadingIndicator = true
        let cardsPageSurface = Surface(path: Constants.SurfaceName.CONTENT_CARD)
        var containerSettings = ContentCardContainerSetting()
        containerSettings.spacing = 35
        containerSettings.scrollDirection = isHorizontalScroll ? .horizontal : .vertical
        
        // Configure pull-to-refresh settings
        var pullToRefreshSettings = PullToRefreshSettings()
        pullToRefreshSettings.isEnabled = true
        pullToRefreshSettings.tintColor = Color.accentColor
        pullToRefreshSettings.backgroundColor = Color(.systemBackground)
        containerSettings.pullToRefresh = pullToRefreshSettings
        
        // Configure header settings        
        if showHeader {
            let headerTitle = AEPText(content: "Inbox Header")
            headerTitle.font = .system(size: 18, weight: .medium)
            headerTitle.textColor = Color(.white)
            var headerSettings = HeaderSettings(title: headerTitle)
            headerSettings.isVisible = true
            headerSettings.backgroundColor = Color(.systemBlue)
            headerSettings.height = 50
            headerSettings.padding = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            containerSettings.header = headerSettings
        }
        
        Messaging.getContentCardsContainerUI(for: cardsPageSurface,
                                     customizer: CardCustomizer(),
                                     listener: self,
                                     settings: containerSettings) { container in
            self.container = container
        }
    }
    
    func downloadCards() {
        showLoadingIndicator = true
        Messaging.updatePropositionsForSurfaces([cardsSurface])
    }
    
    func onDisplay(_ card: ContentCardUI) {
        print("TestAppLog : ContentCard Displayed")
    }
    
    func onDismiss(_ card: ContentCardUI) {
        print("TestAppLog : ContentCard Dismissed")
    }
    
    func onInteract(_ card: ContentCardUI, _ interactionId: String, actionURL: URL?) -> Bool {
        print("TestAppLog : ContentCard Interacted : Interaction - \(interactionId)")
        return false
    }
}

class CardCustomizer : ContentCardCustomizing {
    
    func customize(template: SmallImageTemplate) {
        // customize UI elements
        template.title.textColor = .primary
        template.title.font = .subheadline
        template.body?.textColor = .secondary
        template.body?.font = .caption
        
        template.image?.modifier = AEPViewModifier(ImageModifier())
        
        template.buttons?.first?.text.font = .system(size: 13)
        template.buttons?.first?.text.textColor = .primary
        template.buttons?.first?.modifier = AEPViewModifier(ButtonModifier())
        
        
        // customize stack structure
        template.rootHStack.spacing = 10
        template.textVStack.alignment = .leading
        template.textVStack.spacing = 10
        
        // add custom modifiers
        template.buttonHStack.modifier = AEPViewModifier(ButtonHStackModifier())
        template.rootHStack.modifier = AEPViewModifier(RootHStackModifier())
        
        // customize the dismiss buttons
        template.dismissButton?.image.iconColor = .primary
        template.dismissButton?.image.iconFont = .system(size: 10)
    }
    
    struct RootHStackModifier : ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
    
    struct ButtonHStackModifier : ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    struct ImageModifier : ViewModifier {
        func body(content: Content) -> some View {
            content
                .frame(width: 100, height: 100)
        }
    }
    
    struct ButtonModifier : ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .background(Color.primary.opacity(0.1))
                .cornerRadius(10)
        }
    }
}
