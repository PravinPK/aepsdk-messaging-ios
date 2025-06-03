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

struct CardsView: View, ContainerEventListening {
    
    let cardsSurface = Surface(path: Constants.SurfaceName.CONTENT_CARD)
    @State var container: ContainerUI?
    @State private var isSettingsVisible: Bool = false
    @State private var containerSettings: ContainerSetting = ContainerSetting()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                container?.view
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
                isSettingsVisible: $isSettingsVisible,
                onSettingsChanged: { newSettings in
                    containerSettings = newSettings
                    container?.refreshSettings(newSettings)
                }
            )
            .padding(.horizontal)
            .offset(y: isSettingsVisible ? 0 : UIScreen.main.bounds.height)
            .animation(.spring(), value: isSettingsVisible)
        }
        .onAppear() {
            // Create the container with initial settings
            container = Messaging.getContentCardsContainerUI(for: cardsSurface,
                                                          customizer: CardCustomizer(),
                                                          listener: self,
                                                          settings: containerSettings)
        }
    }
    
    func onDownloading(_ container: AEPMessaging.ContainerUI) {
        print("Peaks: Content cards are downloading")
    }
    
    func onLoaded(_ container: AEPMessaging.ContainerUI) {
        print("Peaks: Content cards have loaded")
    }
    
    func onError(_ container: AEPMessaging.ContainerUI, _ error: any Error) {
        print("Peaks: Error loading content cards: \(error)")
    }
    
    func onEmpty(_ container: AEPMessaging.ContainerUI) {
        print("Peaks: No content cards available")
    }
    
    func onCardDismissed(_ card: AEPMessaging.ContentCardUI) {
        print("Peaks: Card was dismissed")
    }
    
    func onCardDisplayed(_ card: AEPMessaging.ContentCardUI) {
        print("Peaks: Card was displayed")
    }
    
    func onCardInteracted(_ card: AEPMessaging.ContentCardUI, _ interactionId: String, actionURL: URL?) -> Bool {
        print("Peaks: Card was interacted with - Interaction ID: \(interactionId), Action URL: \(actionURL?.absoluteString ?? "none")")
        return false
    }
    
    func onCardCreated(_ card: AEPMessaging.ContentCardUI) {
        if let smallImageCard = card.template as? SmallImageTemplate {
            if let sentDate = card.meta?["sentDate"] as? String {
                smallImageCard.textVStack.addView(Text(sentDate).foregroundColor(.secondary).font(.system(size: 11, weight: .light)))
            }
        }
        
        if let largeImageCard = card.template as? LargeImageTemplate {
            if let sentDate = card.meta?["sentDate"] as? String {
                largeImageCard.textVStack.addView(Text(sentDate).foregroundColor(.secondary).font(.system(size: 11, weight: .light)))
            }
        }
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
        
        template.buttons?.first?.text.font = .system(size: 10)
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
    
    func customize(template: LargeImageTemplate) {
        // customize UI elements
        template.title.textColor = .primary
        template.title.font = .subheadline
        template.body?.textColor = .secondary
        template.body?.font = .caption
                
        template.buttons?.first?.text.font = .system(size: 10)
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
