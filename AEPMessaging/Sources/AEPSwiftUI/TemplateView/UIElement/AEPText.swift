import Foundation
import SwiftUI
import Combine


@available(iOS 13.0, *)
public class AEPText: ObservableObject {
    @Published public var content: String
    @Published public var font: Font?
    @Published public var textColor: Color?
    @Published public var modifier: AEPViewModifier?
    
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
    
    public func setModifier<M: ViewModifier>(_ modi: M) {
        self.modifier = AEPViewModifier(modi)
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
                .applyModifier(model.modifier)
    }
}

@available(iOS 13.0, *)
public extension View {
    func aepModifier<Content: View>(_ modifier: @escaping (Self) -> Content) -> some View {
        return modifier(self)
    }
}



@available(iOS 13.0, *)
public struct AEPViewModifier: ViewModifier {
    private let _body: (Content) -> any View
    
    public init<M: ViewModifier>(_ modifier: M) {
        self._body = { content in
            content.modifier(modifier)
        }
    }
    
    public func body(content: Content) -> some View {
        AnyView(_body(content))
    }
}

@available(iOS 13.0, *)
extension View {
    @ViewBuilder
    func applyModifier(_ modifier: AEPViewModifier?) -> some View {
        self.applyIf(modifier) { $0.modifier($1) }
    }
        
        
    @ViewBuilder
    private func applyIf<Value>(_ value: Value?, apply: (Self, Value) -> some View) -> some View {
        if let value = value {
            apply(self, value)
        } else {
            self
        }
    }
}
