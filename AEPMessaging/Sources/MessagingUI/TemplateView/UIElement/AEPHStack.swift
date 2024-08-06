import SwiftUI
import Combine


@available(iOS 13.0, *)
public class AEPHStack: ObservableObject {
    @Published var views: [AEPViewType] = []
    @Published public var spacing: CGFloat?
    @Published public var alignment: VerticalAlignment?
    
    public lazy var view: AEPHStackView = {
        AEPHStackView(model: self)
    }()
    
//    public func addView<V: AEPView>(_ view: V) {
//        views.append(AnyView(view))
//    }
    
    public func addView(_ view: AEPViewType) {
         views.append(view)
     }
    
    public func removeView(at index: Int) {
        guard views.indices.contains(index) else { return }
        views.remove(at: index)
    }
}

@available(iOS 13.0, *)
public struct AEPHStackView: AEPView {
    
    public init(model: AEPHStack) {
        self.model = model
    }
    
    @ObservedObject public var model = AEPHStack()
    public var body: some View {
        HStack(alignment: model.alignment ?? .center, spacing: model.spacing) {
            ForEach(Array(model.views.enumerated()), id: \.offset) { index, viewType in
                viewType.view
            }
        }
    }
}
