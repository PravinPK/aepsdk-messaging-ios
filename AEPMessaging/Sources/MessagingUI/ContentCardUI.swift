//
//  ContentCardUI.swift
//  AEPMessaging
//
//  Created by Pravin Prakash Kumar on 7/30/24.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
public class ContentCardUI: Identifiable, CardDelegate {
    
    
    private var schemaData : ContentCardSchemaData
    var listener: ContentCardUIEventListener?
    var customizer: ContentCardUICustomizer?
    
    public lazy var view: some View = {
          TemplateView(dataProvider: self, interactionHandler: self)
    }()
    
    init(data: ContentCardSchemaData) {
        self.schemaData = data
    }
}

@available(iOS 13.0, *)
extension ContentCardUI : CardDataSource {
    
    func getTemplateType() -> TemplateType {
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
    
    func getCustomizer() -> ContentCardUICustomizer? {
        return customizer
    }
    
}

@available(iOS 13.0, *)
extension ContentCardUI: CardDelegate {
    
    func cardDisplayed() {
        print("Peaks:ContentCardUI: Recognized Display. Tracking...")
        schemaData.track(withEdgeEventType: .display)
        listener?.didDisplay(self)
    }
    
    func cardDismissed() {
        print("Peaks:ContentCardUI: Recognized Dismiss. Tracking...")
        schemaData.track(withEdgeEventType: .dismiss)
        listener?.didDismiss(self)
    }
    
    func cardInteracted(_ interactionId: String, actionURL url: URL?) {
        print("Peaks:ContentCardUI: Recognized Interaction. Tracking...")
        listener?.didInteract(self, withInteraction: interactionId)
        schemaData.track(interactionId, withEdgeEventType: .interact)
    }
}

/// CardDataSource is responsible for providing the data that the UI components needs to display.
@available(iOS 13.0, *)
protocol CardDataSource {
    
    // Provides the type of the template of the content card
    func getTemplateType() -> TemplateType
    
    // Provide the content for the card
    func getContent() -> [String: Any]?
    
    // Provides the published date of the card
    func getPublishedDate() -> Int?
    
    func getCustomizer() -> ContentCardUICustomizer?
}


/// CardDelegate protocol defines methods that a delegate should implement to handle various card related events .
protocol CardDelegate {
    
    /// Tells the delegate that the card has been displayed
    func cardDisplayed()
    
    /// Tells the delegate that the card has been dismissed
    func cardDismissed()
    
    /// Tells the delegate that the card is interacted.
    func cardInteracted(_ interactionId : String, actionURL url : URL?)
}

enum TemplateType {
    case smallImage
    case largeImage
    case imageOnly
    case unknown
}
