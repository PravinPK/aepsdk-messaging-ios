//
//  AEPView.swift
//  AEPMessaging
//
//  Created by Pravin Prakash Kumar on 8/5/24.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 13.0, *)
public protocol AEPView: View {
    associatedtype Model: ObservableObject
    var model: Model { get }

    init(model: Model)
}


@available(iOS 13.0, *)
public enum AEPViewType: Identifiable {
    case text(AEPTextView)
    case button(AEPButtonView)
    case image(AEPImageView)
    case vStack(AEPVStackView)
    case hStack(AEPHStackView)
    case custom(AnyView)
    
    public var id: UUID {
        UUID()
    }
    
    @ViewBuilder var view: some View {
        switch self {
        case .text(let view):
            view
        case .button(let view):
            view
        case .image(let view):
            view
        case .vStack(let view):
            view
        case .hStack(let view):
            view
        case .custom(let view):
            view
        }
    }
}
