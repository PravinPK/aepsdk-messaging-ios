import SwiftUI
import Combine


@available(iOS 13.0, *)
public class AEPVStack: ObservableObject {
    @Published var views: [AEPViewType] = []
    
    @Published public var spacing: CGFloat?
    @Published public var alignment: HorizontalAlignment?
    
    @Published public var modifier: AEPViewModifier?
    
    public lazy var view: AEPVStackView = {
        AEPVStackView(model: self)
    }()
    
    init(spacing: CGFloat? = nil, alignment: HorizontalAlignment? = nil) {
        self.spacing = spacing
        self.alignment = alignment
    }
    
    public func addView(_ view: AEPViewType) {
         views.append(view)
     }
    
    public func removeView(at index: Int) {
        guard views.indices.contains(index) else { return }
        views.remove(at: index)
    }
    
    public func setModifier<M: ViewModifier>(_ modi: M) {
        self.modifier = AEPViewModifier(modi)
    }
}

@available(iOS 13.0, *)
public struct AEPVStackView: AEPView {
    @ObservedObject public var model: AEPVStack
    
    public init(model: AEPVStack) {
        self.model = model
    }
    
    public var body: some View {
        VStack(alignment: model.alignment ?? .center, spacing: model.spacing) {
            ForEach(Array(model.views.enumerated()), id: \.offset) { index, viewType in
                viewType.view.applyModifier(model.modifier)
            }
        }
    }
}
