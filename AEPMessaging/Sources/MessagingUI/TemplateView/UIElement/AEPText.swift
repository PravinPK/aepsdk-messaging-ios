import Foundation
import SwiftUI
import Combine


@available(iOS 13.0, *)
public class AEPText: ObservableObject {
    @Published public var content: String
    @Published public var font: Font?
    @Published public var textColor: Color?
    @Published public var modifiers: [(Text) -> Text] = []
    
    public var view: any AEPView {
        return AEPTextView(model: self)
    }
    
    public init?(_ data: [String : Any]) {
        guard let content = data["content"] as? String, !content.isEmpty else {
            return nil
        }
        self.content = content
        self.font = nil
        self.textColor = nil
    }
}

@available(iOS 13.0, *)
public struct AEPTextView: AEPView {
    public init(model: AEPText) {
        self.model = model
    }
    @ObservedObject public var model: AEPText
    public var body: some View {
        Text(model.content)
                .font(model.font)
                .foregroundColor(model.textColor)
                .padding()
    }
}

@available(iOS 13.0, *)
public extension View {
    func aepModifier<Content: View>(_ modifier: @escaping (Self) -> Content) -> some View {
        return modifier(self)
    }
}
