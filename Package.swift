// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftPackageAssets",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .macCatalyst(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "PackageAssets",
            targets: ["PackageAssets"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "PackageAssetsMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "PackageAssets", dependencies: ["PackageAssetsMacros"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "PackageAssetsTests",
            dependencies: [
                "PackageAssetsMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        
        .target(
            name: "ExportingClient",
            dependencies: ["PackageAssets"],
            path: "Tests/ExportingClient"
        ),

        .executableTarget(
            name: "ImportingClient",
            dependencies: ["ExportingClient"],
            path: "Tests/ImportingClient",
            swiftSettings: [.define("ENABLE_DEBUG_DYLIB=YES")]
        ),
    ]
)
