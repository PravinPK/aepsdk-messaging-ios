//
//  SmallImageTemplate.swift
//  AEPMessaging
//
//  Created by Pravin Prakash Kumar on 7/30/24.
//

import SwiftUI

@available(iOS 13.0, *)
public struct SmallImageTemplate {

    // element
    public var title : AEPText
    public var body : AEPText?
    public var image: AEPImage?
    public var button : AEPButton?
    
    // layout
    public var rootHStack: AEPHStack
    public var textVStack: AEPVStack
    public var buttonHStack: AEPHStack
    
    private var data : CardDataSource
    
    var actionUrl: URL?
    var interactionHandler: CardDelegate
    
    
    public lazy var view: some View = {
        self.buildViews().onAppear(perform: interactionHandler.cardDisplayed)
    }()
    
    init?(dataProvider: CardDataSource, interactionHandler : CardDelegate) {
        self.data = dataProvider
        guard let content = dataProvider.getContent(),
              let titleData = content["title"] as? [String: Any],
              let title = AEPText(titleData) else {
            return nil
        }
        self.title = title
        self.interactionHandler = interactionHandler
        
        if let bodyData = content["body"] as? [String: Any],
           let body = AEPText(bodyData) {
            self.body = body
        }
        
        if let imageData = content["image"] as? [String: Any] {
            self.image = AEPImage(imageData)
        }
        
        if let buttonData = content["button"] as? [String: Any] {
            self.button = AEPButton(buttonData)
        }
        
        if let actionUrlString = content["actionUrl"] as? String, let url = URL(string: actionUrlString) {
            self.actionUrl = url
        }
                
        self.rootHStack = AEPHStack()
        self.textVStack = AEPVStack(alignment: .leading)
        self.buttonHStack = AEPHStack()
    }
    
    
    private func buildViews() -> some View {
        data.getCustomizer()?.customize(forTemplate: self)
        textVStack.addView(.text(AEPTextView(model: title)))
        
        if let body = body {
            textVStack.addView(.text(AEPTextView(model: body)))
        }
        
        if let button = button {
            buttonHStack.addView(.button(AEPButtonView(model: button)))
            textVStack.addView(.hStack(buttonHStack.view))
        }
        
        if let image = image {
            rootHStack.addView(.image(AEPImageView(model: image)))
        }
        
        rootHStack.addView(.vStack(textVStack.view))

        return rootHStack.view
    }
}
