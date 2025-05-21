// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "AEPMessagingMacros",
    platforms: [.macOS(.v10_15), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v15)],
    products: [
        .library(
            name: "AEPMessagingMacros",
            targets: ["AEPMessagingMacros"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "AEPMessagingMacrosMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "AEPMessagingMacros",
            dependencies: ["AEPMessagingMacrosMacros"]
        ),
        .testTarget(
            name: "AEPMessagingMacrosTests",
            dependencies: [
                "AEPMessagingMacrosMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
) 