//
//  LargeImageTemplate.swift
//  AEPMessaging
//
//  Created by Pravin Prakash Kumar on 7/30/24.
//

import SwiftUI

@available(iOS 13.0, *)
struct LargeImageTemplate {    
    public var image: Image?
    public var title : String?
    public var body : Text?
    
    
    init(dataProvider: CardDataProvider) {
        if let content = dataProvider.getContent(),
           let titleData = content["title"] as? [String: Any],
           let titleText = titleData["text"] as? String {
            self.title = titleText
        } else {
            self.title = "No text"
        }
    }
}

@available(iOS 13.0, *)
struct LargeImageTemplateView : View {
    var model : LargeImageTemplate
    var interactionHandler: CardInteractionHandler
    
    var body: some View {
        HStack {
            Text("Large Image Template")
            Button(action: {
                interactionHandler.cardInteracted("Click me")
            }, label: {
                Text("Click me")
            })
            Button(action: {
                interactionHandler.cardDismissed()
            }, label: {
                Text("Close")
            })
        }
    }
}
