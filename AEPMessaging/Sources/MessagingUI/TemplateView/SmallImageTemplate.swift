//
//  SmallImageTemplate.swift
//  AEPMessaging
//
//  Created by Pravin Prakash Kumar on 7/30/24.
//

import SwiftUI

@available(iOS 13.0, *)
public struct SmallImageTemplate {
    
    public var title : AEPText
    public var body : AEPText?
    public var image: AEPImage?
    public var button : AEPButton?
    
    public var rootHStack: AEPHStack
    public var textVStack: AEPVStack
    public var buttonHStack: AEPHStack
    var actionUrl: URL?
    
    var interactionHandler: CardInteractionHandler
    
    public static var customize: ((inout SmallImageTemplate) -> Void)?
    
    public lazy var view: some View = {
        self.buildViews()
    }()
    
    init?(dataProvider: CardDataProvider, interactionHandler : CardInteractionHandler) {
        
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
    
    public mutating func applyCustomization() {
        if let customization = SmallImageTemplate.customize {
            customization(&self)
        }
    }
    
    private func buildViews() -> some View {
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
        
        var mutableSelf = self
        mutableSelf.applyCustomization()
        return rootHStack.view
    }
}

//@available(iOS 13.0, *)
//struct SmallImageTemplateView : View {
//    
//    var model: SmallImageTemplate
//    
//    @State private var isVisible = true
//    var body: some View {
//        if isVisible {
//            model.buildViews()
//        } else {
//            EmptyView()
//        }
//    }
//}


//private func buildViews() -> some View {
//    textVStack.addView(title.view)
//    
//    if let body = body {
//        textVStack.addView(body.view)
//    }
//            
//    if let button = button {
//        buttonHStack.addView(button.view)
//        textVStack.addView(buttonHStack.view)
//    }
//    
//    if let image = image {
//        rootHStack.addView(image.view)
//    }
//
//    rootHStack.addView(textVStack.view)
//    
//    var mutableSelf = self
//    mutableSelf.applyCustomization()
//    return rootHStack.view
//}
