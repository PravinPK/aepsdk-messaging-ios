//
//  AEPButton.swift
//  ContentCardUIFramework
//
//  Created by Pravin Prakash Kumar on 7/21/24.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 13.0, *)
public class AEPButton: ObservableObject {
    @Published public var text: AEPText
    @Published public var interactId: String
    @Published public var actionUrl: String?
    
    public lazy var view: some AEPView = {
        AEPButtonView(model: self)
    }()

    public init?(_ data: [String: Any]) {
        guard let interactId = data["interactId"] as? String else {
             return nil
         }
         
         guard let textData = data["text"] as? [String: Any],
               let text = AEPText(textData) else {
             return nil
         }
         
         self.interactId = interactId
         self.text = text
         self.actionUrl = data["actionUrl"] as? String
    }

}

@available(iOS 13.0, *)
public struct AEPButtonView: AEPView {
    @ObservedObject public var model: AEPButton
    
    public init(model: AEPButton) {
        self.model = model
    }
    
    public var body: some View {
        Button(action: {            
        }, label: {
            Text("Hello")
        })
    }
}
