import Foundation
import SwiftUI
import Combine


@available(iOS 13.0, *)
public class AEPImage: ObservableObject {
    @Published public var url: String?
    
    @Published public var darkUrl: String?
    @Published public var bundle: String?
    @Published public var darkBundle: String?
    @Published public var contentMode : ContentMode = .fit
    
    public lazy var view: some AEPView = {
        AEPImageView(model: self)
    }()

    init?(_ data: [String : Any]) {
        
        if let url = data["url"] as? String {
            self.url = url
        }
        
        if let darkUrl = data["darkUrl"] as? String {
            self.darkUrl = darkUrl
        }
        
        if let bundle = data["bundle"] as? String {
            self.bundle = bundle
        }
        
        if let darkBundle = data["darkBundle"] as? String {
            self.darkBundle = darkBundle
        }
    }
}

@available(iOS 13.0, *)
public struct AEPImageView: AEPView {
    @ObservedObject public var model: AEPImage
    
    public init(model: AEPImage) {
        self.model = model
    }
    
    public var body: some View {
        Image(model.bundle!)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

