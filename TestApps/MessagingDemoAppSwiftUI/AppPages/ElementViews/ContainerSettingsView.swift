import SwiftUI

struct ContainerSettingsView: View {
    @Binding var isHorizontalScroll: Bool
    @Binding var showHeader: Bool
    @Binding var isSettingsVisible: Bool
    let onSettingsChanged: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Chevron Button
            Image(systemName: "chevron.down")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(.systemGray3))
                .frame(height: 24)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .onTapGesture {
                    withAnimation {
                        isSettingsVisible = false
                    }
                }
            
            // Settings Panel
            VStack(spacing: 16) {
                Text("Container Settings")
                    .font(.headline)
                    .padding(.top, 8)
                
                // Settings Controls
                VStack(spacing: 16) {
                    Toggle("Horizontal Scroll", isOn: $isHorizontalScroll)
                        .onChange(of: isHorizontalScroll) { _ in
                            onSettingsChanged()
                        }
                    
                    Toggle("Show Header", isOn: $showHeader)
                        .onChange(of: showHeader) { _ in
                            onSettingsChanged()
                        }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(radius: 10)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height > 50 {
                        withAnimation {
                            isSettingsVisible = false
                        }
                    }
                }
        )
    }
}

// Helper extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                              cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
