//
//  TemplateView.swift
//  AEPMessaging
//
//  Created by Pravin Prakash Kumar on 7/30/24.
//

import SwiftUI

@available(iOS 13.0, *)
public struct TemplateView: View {    
    var dataProvider: CardDataSource
    var interactionHandler: CardDelegate
    
    public var body: some View {
        switch dataProvider.getTemplateType() {
            
        case .smallImage:
            var template = SmallImageTemplate(dataProvider: dataProvider, interactionHandler: interactionHandler)
            template?.view
        case .largeImage:
            let model = LargeImageTemplate(dataProvider: dataProvider)
            LargeImageTemplateView(model: model, interactionHandler: interactionHandler)

        case .imageOnly:
            EmptyView()
            
        case .unknown:
            EmptyView()
        }
    }
}
