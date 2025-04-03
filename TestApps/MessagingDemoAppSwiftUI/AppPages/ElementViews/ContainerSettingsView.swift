import SwiftUI
import AEPMessaging

struct ContainerSettingsView: View {
    @Binding var isSettingsVisible: Bool
    @State private var settings: ContentCardContainerSetting
    let onSettingsChanged: (ContentCardContainerSetting) -> Void
    
    init(isSettingsVisible: Binding<Bool>, onSettingsChanged: @escaping (ContentCardContainerSetting) -> Void) {
        self._isSettingsVisible = isSettingsVisible
        self._settings = State(initialValue: ContentCardContainerSetting())
        self.onSettingsChanged = onSettingsChanged
    }
    
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
                    Toggle("Horizontal Scroll", isOn: Binding(
                        get: { settings.scrollDirection == .horizontal },
                        set: { isHorizontal in
                            settings.scrollDirection = isHorizontal ? .horizontal : .vertical
                            onSettingsChanged(settings)
                        }
                    ))
                    
                    Toggle("Show Header", isOn: Binding(
                        get: { settings.header?.isVisible ?? false },
                        set: { showHeader in
                            if showHeader {
                                let headerTitle = AEPText(content: "Inbox Header")
                                headerTitle.font = .system(size: 18, weight: .medium)
                                headerTitle.textColor = Color(.white)
                                var headerSettings = HeaderSettings(title: headerTitle)
                                headerSettings.isVisible = true
                                headerSettings.backgroundColor = Color(.systemBlue)
                                headerSettings.height = 50
                                headerSettings.padding = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                                settings.header = headerSettings
                            } else {
                                settings.header = nil
                            }
                            onSettingsChanged(settings)
                        }
                    ))
                    
                    Toggle("Pull to Refresh", isOn: Binding(
                        get: { settings.pullToRefresh.isEnabled },
                        set: { isEnabled in
                            settings.pullToRefresh.isEnabled = isEnabled
                            onSettingsChanged(settings)
                        }
                    ))
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
