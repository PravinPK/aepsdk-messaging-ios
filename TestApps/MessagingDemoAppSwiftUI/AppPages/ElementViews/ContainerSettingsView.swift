import SwiftUI
import AEPMessaging

struct ContainerSettingsView: View {
    @Binding var isSettingsVisible: Bool
    @State private var settings: ContainerSetting
    let onSettingsChanged: (ContainerSetting) -> Void
    
    init(isSettingsVisible: Binding<Bool>, onSettingsChanged: @escaping (ContainerSetting) -> Void) {
        self._isSettingsVisible = isSettingsVisible
        self._settings = State(initialValue: ContainerSetting())
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
            ScrollView {
                VStack(spacing: 16) {
                    Text("Container Settings")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    // Settings Controls
                    VStack(spacing: 24) {
                        // Layout Settings
                        SettingsSection(title: "Layout") {
                            Picker("Layout Direction", selection: Binding(
                                get: { settings.layout },
                                set: { newLayout in
                                    settings.layout = newLayout
                                    onSettingsChanged(settings)
                                }
                            )) {
                                Text("Horizontal").tag(ContainerLayout.horizontal)
                                Text("Vertical").tag(ContainerLayout.vertical)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            ColorPicker("Container Background", selection: Binding(
                                get: { settings.backgroundColor },
                                set: { color in
                                    settings.backgroundColor = color
                                    onSettingsChanged(settings)
                                }
                            ))
                        }
                        
                        // Header Settings
                        SettingsSection(title: "Header") {
                            Toggle("Show Header", isOn: Binding(
                                get: { settings.header?.isVisible ?? false },
                                set: { showHeader in
                                    if showHeader {
                                        let headerTitle = AEPText(content: settings.header?.title.content ?? "Inbox Header")
                                        headerTitle.font = settings.header?.title.font ?? .system(size: 18, weight: .medium)
                                        headerTitle.textColor = settings.header?.title.textColor ?? Color(.white)
                                        var headerSettings = HeaderSettings(title: headerTitle)
                                        headerSettings.isVisible = true
                                        headerSettings.backgroundColor = settings.header?.backgroundColor ?? Color(.systemBlue)
                                        headerSettings.height = settings.header?.height ?? 50
                                        headerSettings.padding = settings.header?.padding ?? EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                                        settings.header = headerSettings
                                    } else {
                                        settings.header = nil
                                    }
                                    onSettingsChanged(settings)
                                }
                            ))
                            
                            if settings.header?.isVisible ?? false {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Header Style")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                    
                                    TextField("Header Title", text: Binding(
                                        get: { settings.header?.title.content ?? "" },
                                        set: { newTitle in
                                            if var header = settings.header {
                                                header.title.content = newTitle
                                                settings.header = header
                                                onSettingsChanged(settings)
                                            }
                                        }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    HStack {
                                        Text("Header Height")
                                        Spacer()
                                        TextField("Height", value: Binding(
                                            get: { Double(settings.header?.height ?? 50) },
                                            set: { newHeight in
                                                if var header = settings.header {
                                                    header.height = CGFloat(newHeight)
                                                    settings.header = header
                                                    onSettingsChanged(settings)
                                                }
                                            }
                                        ), format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .keyboardType(.numberPad)
                                    }
                                    
                                    ColorPicker("Header Background", selection: Binding(
                                        get: { settings.header?.backgroundColor ?? Color(.systemBlue) },
                                        set: { color in
                                            if var header = settings.header {
                                                header.backgroundColor = color
                                                settings.header = header
                                                onSettingsChanged(settings)
                                            }
                                        }
                                    ))
                                    
                                    ColorPicker("Header Text Color", selection: Binding(
                                        get: { settings.header?.title.textColor ?? Color(.white) },
                                        set: { color in
                                            if var header = settings.header {
                                                header.title.textColor = color
                                                settings.header = header
                                                onSettingsChanged(settings)
                                            }
                                        }
                                    ))
                                }
                                .padding(.leading, 8)
                            }
                        }
                        
                        // Pull to Refresh Settings
                        SettingsSection(title: "Pull to Refresh") {
                            Toggle("Enable Pull to Refresh", isOn: Binding(
                                get: { settings.pullToRefresh.isEnabled },
                                set: { isEnabled in
                                    settings.pullToRefresh.isEnabled = isEnabled
                                    onSettingsChanged(settings)
                                }
                            ))
                        }
                        
                        // Unread State Settings
                        SettingsSection(title: "Unread State") {
                            Toggle("Enable Unread Indicator", isOn: Binding(
                                get: { settings.unreadState.isEnabled },
                                set: { isEnabled in
                                    settings.unreadState.isEnabled = isEnabled
                                    onSettingsChanged(settings)
                                }
                            ))
                            
                            if settings.unreadState.isEnabled {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Indicator Style")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                    
                                    Picker("Icon Position", selection: Binding(
                                        get: { settings.unreadState.iconPosition },
                                        set: { position in
                                            settings.unreadState.iconPosition = position
                                            onSettingsChanged(settings)
                                        }
                                    )) {
                                        Text("Top Left").tag(UnreadPosition.topLeft)
                                        Text("Top Right").tag(UnreadPosition.topRight)
                                        Text("Right").tag(UnreadPosition.right)
                                        Text("Left").tag(UnreadPosition.left)
                                        Text("Bottom Left").tag(UnreadPosition.bottomLeft)
                                        Text("Bottom Right").tag(UnreadPosition.bottomRight)
                                    }
                                    .pickerStyle(.menu)
                                    
                                    ColorPicker("Indicator Color", selection: Binding(
                                        get: { settings.unreadState.backgroundColor },
                                        set: { color in
                                            settings.unreadState.backgroundColor = color
                                            onSettingsChanged(settings)
                                        }
                                    ))
                                }
                                .padding(.leading, 8)
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
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

// Settings Section View
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
