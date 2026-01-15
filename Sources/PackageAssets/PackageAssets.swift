@_exported import DeveloperToolsSupport
import Foundation

public enum AccessLevel {
    case `package`
    case `public`
}

@resultBuilder
public enum ResourcesBuilder<T: Hashable & Sendable> {
    public static func buildExpression(_ expr: T) -> [T] {
        [expr]
    }

    public static func buildBlock(_ components: [T]...) -> [T] {
        components.flatMap { $0 }
    }
}

// MARK: Color Resource Macro

@freestanding(declaration, names: arbitrary)
public macro ColorResource(
    _ accessLevel: AccessLevel = .public,
    @ResourcesBuilder<ColorResource> _ resourcesBuilder: () -> [ColorResource]
) = #externalMacro(module: "PackageAssetsMacros", type: "ColorResourceMacro")

@freestanding(declaration, names: arbitrary)
public macro ColorResource(
    _ accessLevel: AccessLevel = .public,
    resources: [ColorResource]
) = #externalMacro(module: "PackageAssetsMacros", type: "ColorResourceMacro")

// MARK: Image Resource Macro

@freestanding(declaration, names: arbitrary)
public macro ImageResource(
    _ accessLevel: AccessLevel = .public,
    @ResourcesBuilder<ImageResource> _ resourcesBuilder: () -> [ImageResource]
) = #externalMacro(module: "PackageAssetsMacros", type: "ImageResourceMacro")

@freestanding(declaration, names: arbitrary)
public macro ColorResource(
    _ accessLevel: AccessLevel = .public,
    resources: [ImageResource]
) = #externalMacro(module: "PackageAssetsMacros", type: "ColorResourceMacro")

// MARK: - Types

public enum Assets {

    public struct ImageResource: Sendable {
        var imageResource: DeveloperToolsSupport.ImageResource
        public init(_ imageResource: DeveloperToolsSupport.ImageResource) {
            self.imageResource = imageResource
        }
        
        public typealias R = DeveloperToolsSupport.ImageResource
    }

    public struct ColorResource: Sendable {
        var colorResource: DeveloperToolsSupport.ColorResource
        public init(_ colorResource: DeveloperToolsSupport.ColorResource) {
            self.colorResource = colorResource
        }
        
        public typealias R = DeveloperToolsSupport.ColorResource
    }
}

// MARK: - Initializers (AppKit, UIKit, SwiftUI)

#if canImport(AppKit)
import AppKit

extension NSColor {
    @_disfavoredOverload
    public convenience init(resource: Assets.ColorResource) {
        self.init(resource: resource.colorResource)
    }
}
extension NSImage {
    @_disfavoredOverload
    public convenience init(resource: Assets.ImageResource) {
        self.init(resource: resource.imageResource)
    }
}

#endif

#if canImport(UIKit)
import UIKit

extension UIColor {
    @_disfavoredOverload
    public convenience init(resource: Assets.ColorResource) {
        self.init(resource: resource.colorResource)
    }
}

extension UIImage {
    @_disfavoredOverload
    public convenience init(resource: Assets.ImageResource) {
        self.init(resource: resource.imageResource)
    }
}
#endif

#if canImport(SwiftUI)
import SwiftUI

extension Color {
    @_disfavoredOverload
    public init(_ colorResource: Assets.ColorResource) {
        self.init(colorResource.colorResource)
    }
}

extension Image {
    @_disfavoredOverload
    public init(_ publicResource: Assets.ImageResource) {
        self.init(publicResource.imageResource)
    }
}
#endif

