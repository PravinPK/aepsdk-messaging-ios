//
//  ContentCardUI.swift
//  AEPMessaging
//
//  Created by Pravin Prakash Kumar on 7/30/24.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
public class ContentCardUI: Identifiable, CardInteractionHandler {
    
    private var schemaData : ContentCardSchemaData
    public var listener: ContentCardUIEventListener?
    
    public lazy var view: some View = {
          TemplateView(dataProvider: self, interactionHandler: self)
    }()
    
    init(data: ContentCardSchemaData) {
        self.schemaData = data
    }
    
    func recordEvent(eventType: String, interaction: String) {
        
    }
}

@available(iOS 13.0, *)
public protocol ContentCardUIEventListener {
    func didDisplay(_ card: ContentCardUI)
    func didDismiss(_ card: ContentCardUI)
    func didInteract(_ card: ContentCardUI, withInteraction: String?)
}

@available(iOS 13.0, *)
extension ContentCardUI : CardDataProvider {
    
    func getTemplateType() -> Template {
        guard let meta = schemaData.meta else {
            return .unknown
        }
        guard meta["adb_template"] != nil else {
            return .unknown
        }
        return .smallImage
    }
    
    func getContent() -> [String : Any]? {
        schemaData.content as? [String: Any]
    }
    
    func getPublishedDate() -> Int? {
        return schemaData.publishedDate
    }
}

@available(iOS 13.0, *)
extension ContentCardUI : CardInteractionHandler {
    
    func cardDisplayed() {
        print("Peaks:ContentCardUI: Recognized Display. Tracking...")
        schemaData.track(withEdgeEventType: .display)
    }
    
    func cardDismissed() {
        print("Peaks:ContentCardUI: Recognized Dismiss. Tracking...")
        schemaData.track(withEdgeEventType: .dismiss)
        listener?.didDismiss(self)
    }
    
    func cardInteracted(_ interaction : String) {
        print("Peaks:ContentCardUI: Recognized Interaction. Tracking...")
        listener?.didInteract(self, withInteraction: interaction)
        schemaData.track(interaction, withEdgeEventType: .interact)
    }
}

protocol CardDataProvider {
    func getTemplateType() -> Template
    
    func getContent() -> [String: Any]?
    
    func getPublishedDate() -> Int?
}

protocol CardInteractionHandler {

    func cardDisplayed()
    
    func cardDismissed()
    
    func cardInteracted(_ interaction : String)
}

enum Template {
    case smallImage
    case largeImage
    case imageOnly
    case unknown
}



