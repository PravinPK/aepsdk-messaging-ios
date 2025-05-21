import Foundation

/// Protocol for types that expose metadata about their properties
@available(iOS 16.1, *)
public protocol _ExposesMetadata {
    /// Get metadata about the type's properties
    static var __metadata: PropertyMetadata { get }
}

/// Represents metadata about a type's properties
@available(iOS 16.1, *)
public struct PropertyMetadata {
    /// Array of tuples containing property name and type
    public var properties: [(name: String, type: Any.Type)]
    
    /// Initialize with property information
    public init(properties: [(name: String, type: Any.Type)]) {
        self.properties = properties
    }
    
    /// Get a formatted representation of the properties
    public func expanded() -> String {
        return properties.map { "(\"\($0.name)\", \(String(describing: $0.type)))" }.description
    }
}

/// Macro that adds metadata exposure to types
///
/// Apply this to structs conforming to LiveActivityAttributes, ContentState,
/// or any nested struct to expose property information at compile time.
@available(iOS 16.1, *)
@attached(member, names: named(__metadata))
@attached(conformance)
public macro AttributeMetadataMacro() = #externalMacro(module: "AEPMessagingMacros", type: "AttributeMetadataMacro") 