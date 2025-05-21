import SwiftUI
import AEPMessaging

@available(iOS 16.1, *)
struct MacroTestView: View {
    @State private var metadataResult: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("AttributeMetadataMacro Demo")
                    .font(.title)
                    .padding(.bottom, 10)
                
                Text("This demo shows how Swift macros can be used to extract property information at compile time. This avoids runtime reflection and makes the code more reliable.")
                    .font(.body)
                    .padding(.bottom, 10)
                
                Button("Test Metadata Extraction") {
                    metadataResult = debugDumpAttributes(AirplaneTrackingAttributes.self)
                }
                .buttonStyle(.borderedProminent)
                
                if !metadataResult.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Extracted Metadata:")
                            .font(.headline)
                        
                        Text(metadataResult)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Macro Testing")
    }
}

@available(iOS 16.1, *)
struct MacroTestView_Previews: PreviewProvider {
    static var previews: some View {
        MacroTestView()
    }
} 