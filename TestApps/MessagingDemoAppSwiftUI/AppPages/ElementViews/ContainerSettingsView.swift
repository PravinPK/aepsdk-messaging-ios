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
                        // Container Capacity Settings
                        SettingsSection(title: "Container Capacity") {
                            HStack {
                                Text("Number of cards")
                                Spacer()
                                TextField("Number of cards", value: Binding(
                                    get: { Double(settings.capacity) },
                                    set: { newCapacity in
                                        settings.capacity = Int(newCapacity)
                                        onSettingsChanged(settings)
                                    }
                                ), format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                                .keyboardType(.numberPad)
                                .onChange(of: settings.capacity) { newValue in
                                    if newValue < 1 {
                                        settings.capacity = 1
                                        onSettingsChanged(settings)
                                    }
                                }
                            }
                        }
                        
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
                            
                            HStack {
                                Text("Card Spacing")
                                Spacer()
                                TextField("Spacing", value: Binding(
                                    get: { Double(settings.spacing) },
                                    set: { newSpacing in
                                        settings.spacing = CGFloat(newSpacing)
                                        onSettingsChanged(settings)
                                    }
                                ), format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                                .keyboardType(.numberPad)
                            }
                            
                            // Card Dimensions
                            HStack {
                                Text("Card Height")
                                Spacer()
                                TextField("Height", value: Binding(
                                    get: { settings.cardHeight.map { Double($0) } ?? 0 },
                                    set: { newHeight in
                                        settings.cardHeight = newHeight > 0 ? CGFloat(newHeight) : nil
                                        onSettingsChanged(settings)
                                    }
                                ), format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                                .keyboardType(.numberPad)
                                .onChange(of: settings.cardHeight) { newValue in
                                    if let height = newValue, height < 0 {
                                        settings.cardHeight = nil
                                        onSettingsChanged(settings)
                                    }
                                }
                            }
                            
                            HStack {
                                Text("Card Width")
                                Spacer()
                                TextField("Width", value: Binding(
                                    get: { settings.cardWidth.map { Double($0) } ?? 0 },
                                    set: { newWidth in
                                        settings.cardWidth = newWidth > 0 ? CGFloat(newWidth) : nil
                                        onSettingsChanged(settings)
                                    }
                                ), format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                                .keyboardType(.numberPad)
                                .onChange(of: settings.cardWidth) { newValue in
                                    if let width = newValue, width < 0 {
                                        settings.cardWidth = nil
                                        onSettingsChanged(settings)
                                    }
                                }
                            }
                            
                            ColorPicker("Container Background", selection: Binding(
                                get: { settings.backgroundColor },
                                set: { color in
                                    settings.backgroundColor = color
                                    onSettingsChanged(settings)
                                }
                            ))
                        }
                        
                        // Header Settings - Toggle in Section header
                        ToggleableSettingsSection(
                            title: "Header",
                            isEnabled: Binding(
                                get: { settings.header?.isVisible ?? false },
                                set: { showHeader in
                                    if showHeader {
                                        let headerTitle = AEPText(content: settings.header?.title.content ?? "Inbox Header")
                                        headerTitle.font = settings.header?.title.font ?? .system(size: 18, weight: .medium)
                                        headerTitle.textColor = settings.header?.title.textColor ?? Color(.white)
                                        var headerSettings = ContainerHeader(title: headerTitle)
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
                            )
                        ) {
                            if settings.header?.isVisible ?? false {
                                VStack(alignment: .leading, spacing: 12) {
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
                            }
                        }
                        
                        // Pull to Refresh Settings - Toggle in section header
                        ToggleableSettingsSection(
                            title: "Pull to Refresh",
                            isEnabled: Binding(
                                get: { settings.pullToRefresh.isEnabled },
                                set: { isEnabled in
                                    settings.pullToRefresh.isEnabled = isEnabled
                                    onSettingsChanged(settings)
                                }
                            )
                        ) {
                            if settings.pullToRefresh.isEnabled {
                                ColorPicker("Refresh Indicator Color", selection: Binding(
                                    get: { settings.pullToRefresh.tintColor },
                                    set: { color in
                                        settings.pullToRefresh.tintColor = color
                                        onSettingsChanged(settings)
                                    }
                                ))
                            }
                        }
                        
                        // Unread State Settings - Toggle in section header
                        ToggleableSettingsSection(
                            title: "Unread State",
                            isEnabled: Binding(
                                get: { settings.unreadState.isEnabled },
                                set: { isEnabled in
                                    settings.unreadState.isEnabled = isEnabled
                                    onSettingsChanged(settings)
                                }
                            )
                        ) {
                            if settings.unreadState.isEnabled {
                                // Background Indicator
                                ToggleableSettingsSection(
                                    title: "Background Indicator",
                                    isEnabled: Binding(
                                        get: { settings.unreadState.backgroundColor != nil },
                                        set: { isEnabled in
                                            if isEnabled {
                                                settings.unreadState.backgroundColor = .red
                                            } else {
                                                settings.unreadState.backgroundColor = nil
                                            }
                                            onSettingsChanged(settings)
                                        }
                                    )
                                ) {
                                    ColorPicker("Background Color", selection: Binding(
                                        get: { settings.unreadState.backgroundColor ?? .red },
                                        set: { color in
                                            settings.unreadState.backgroundColor = color
                                            onSettingsChanged(settings)
                                        }
                                    ))
                                }
                                
                                // Bar Indicator
                                ToggleableSettingsSection(
                                    title: "Bar Indicator",
                                    isEnabled: Binding(
                                        get: { settings.unreadState.barThickness != nil },
                                        set: { isEnabled in
                                            if isEnabled {
                                                settings.unreadState.barColor = .blue
                                                settings.unreadState.barThickness = 4
                                            } else {
                                                settings.unreadState.barColor = .blue
                                                settings.unreadState.barThickness = nil
                                            }
                                            onSettingsChanged(settings)
                                        }
                                    )
                                ) {
                                    ColorPicker("Bar Color", selection: Binding(
                                        get: { settings.unreadState.barColor ?? .blue },
                                        set: { color in
                                            settings.unreadState.barColor = color
                                            onSettingsChanged(settings)
                                        }
                                    ))
                                    
                                    HStack {
                                        Text("Bar Thickness")
                                        Spacer()
                                        TextField("Thickness", value: Binding(
                                            get: { Double(settings.unreadState.barThickness ?? 4) },
                                            set: { thickness in
                                                settings.unreadState.barThickness = CGFloat(thickness)
                                                onSettingsChanged(settings)
                                            }
                                        ), format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .keyboardType(.numberPad)
                                    }
                                    
                                    Picker("Bar Position", selection: Binding(
                                        get: { IconPosition(from: settings.unreadState.barPosition) },
                                        set: { position in
                                            settings.unreadState.barPosition = position.alignment
                                            onSettingsChanged(settings)
                                        }
                                    )) {
                                        Text("Leading").tag(IconPosition.leading)
                                        Text("Trailing").tag(IconPosition.trailing)
                                        Text("Top").tag(IconPosition.top)
                                        Text("Bottom").tag(IconPosition.bottom)
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                // Icon Indicator
                                ToggleableSettingsSection(
                                    title: "Icon Indicator",
                                    isEnabled: Binding(
                                        get: { settings.unreadState.icon != nil },
                                        set: { isEnabled in
                                            if isEnabled {
                                                settings.unreadState.icon = AEPImage(icon: "circle.fill", color: .red)
                                            } else {
                                                settings.unreadState.icon = nil
                                            }
                                            onSettingsChanged(settings)
                                        }
                                    )
                                ) {
                                    TextField("Icon Name (SF Symbol)", text: Binding(
                                        get: { settings.unreadState.icon?.icon ?? "circle.fill" },
                                        set: { iconName in
                                            if settings.unreadState.icon == nil {
                                                settings.unreadState.icon = AEPImage(icon: iconName, color: .red)
                                            } else {
                                                settings.unreadState.icon?.icon = iconName
                                            }
                                            onSettingsChanged(settings)
                                        }
                                    ))
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    ColorPicker("Icon Color", selection: Binding(
                                        get: { settings.unreadState.icon?.iconColor ?? .red },
                                        set: { color in
                                            settings.unreadState.icon?.iconColor = color
                                            onSettingsChanged(settings)
                                        }
                                    ))
                                    
                                    Picker("Icon Position", selection: Binding(
                                        get: { IconPosition(from: settings.unreadState.iconPosition) },
                                        set: { position in
                                            settings.unreadState.iconPosition = position.alignment
                                            onSettingsChanged(settings)
                                        }
                                    )) {
                                        Text("Top Left").tag(IconPosition.topLeading)
                                        Text("Top Right").tag(IconPosition.topTrailing)
                                        Text("Bottom Left").tag(IconPosition.bottomLeading)
                                        Text("Bottom Right").tag(IconPosition.bottomTrailing)
                                        Text("Top").tag(IconPosition.top)
                                        Text("Bottom").tag(IconPosition.bottom)
                                        Text("Leading").tag(IconPosition.leading)
                                        Text("Trailing").tag(IconPosition.trailing)
                                        Text("Center").tag(IconPosition.center)
                                    }
                                    .pickerStyle(.menu)
                                }
                            }
                        }
                        
                        // Empty State Settings
                        ToggleableSettingsSection(
                            title: "Empty State",
                            isEnabled: Binding(
                                get: { true }, // Always enabled, but we'll use it for UI consistency
                                set: { _ in }
                            ),
                            showToggle: false
                        ) {
                            TextField("Empty State Message", text: Binding(
                                get: { settings.emptyState.message.content },
                                set: { newMessage in
                                    settings.emptyState.message.content = newMessage
                                    onSettingsChanged(settings)
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            ColorPicker("Message Color", selection: Binding(
                                get: { settings.emptyState.message.textColor ?? .primary },
                                set: { color in
                                    settings.emptyState.message.textColor = color
                                    onSettingsChanged(settings)
                                }
                            ))
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
            
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// Toggleable Settings Section View
struct ToggleableSettingsSection<Content: View>: View {
    let title: String
    @Binding var isEnabled: Bool
    let content: Content
    let showToggle: Bool
    
    init(title: String, isEnabled: Binding<Bool>, showToggle: Bool = true, @ViewBuilder content: () -> Content) {
        self.title = title
        self._isEnabled = isEnabled
        self.content = content()
        self.showToggle = showToggle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with Toggle
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if showToggle {
                    Toggle("", isOn: $isEnabled)
                        .labelsHidden()
                }
            }
            
            // Content
            if !showToggle || isEnabled {
                VStack(alignment: .leading, spacing: 12) {
                    content
                }
                .padding(.top, 4)
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

// Define a custom enum for alignment options
enum IconPosition: Hashable {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
    case top
    case bottom
    case leading
    case trailing
    case center

    // Map to SwiftUI Alignment
    var alignment: Alignment {
        switch self {
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        case .center: return .center
        }
    }

    init(from alignment: Alignment) {
        switch alignment {
        case .topLeading: self = .topLeading
        case .topTrailing: self = .topTrailing
        case .bottomLeading: self = .bottomLeading
        case .bottomTrailing: self = .bottomTrailing
        case .top: self = .top
        case .bottom: self = .bottom
        case .leading: self = .leading
        case .trailing: self = .trailing
        case .center: self = .center
        default: self = .topLeading
        }
    }
}

// Add this enum at the bottom of the file
enum UnreadIndicatorType {
    case background
    case bar
    case icon
    
    static func current(for state: UnreadState) -> UnreadIndicatorType {
        if state.backgroundColor != nil {
            return .background
        } else if state.barThickness != nil {
            return .bar
        } else if state.icon != nil {
            return .icon
        }
        return .background // Default
    }
}
