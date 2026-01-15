# Asset Resource Exporter

Export ImageResource and ColorResource symbols generated from .xcassets so they can be used outside the defining Swift module. This is especially useful in modularized apps using Swift Package Manager, where Xcode generates these symbols as internal by default.

## Why this exists

- Xcode automatically generates `ImageResource` and `ColorResource` symbols for assets in `.xcassets`, but marks them as `internal` within the Swift module that defines them.
- In modularized projects (especially SPM-based), you often need to reference shared assets from other modules without exposing the whole asset catalog or duplicating names.
- This package provides a simple way to re-expose those generated symbols as `public` or `package` so they can be imported and used by other modules safely and ergonomically.

## What it does

- Maps your xcassets namespaces and re-exports the generated symbols.
- Supports adding your own additional enum namespaces to group assets logically.
- Lets you choose the desired visibility: `public` or `package`.
- Works seamlessly with:
  - UIKit/AppKit: `UIImage`, `UIColor`, `NSImage`, `NSColor`
  - SwiftUI: `Image`, `Color`

## Supported Platforms & Types

- iOS, iPadOS: `UIImage`, `UIColor`, SwiftUI `Image`, `Color`
- macOS: `NSImage`, `NSColor`, SwiftUI `Image`, `Color`
- tvOS, watchOS: `UIImage`/`UIColor` where applicable, SwiftUI `Image`/`Color`

Use the exported `ImageResource` and `ColorResource` values directly with the initializers provided by Apple frameworks.

## Installation

`Package.swift`:

```swift
// Add the dependency
.package(url: "https://github.com/quentinfasquel/SwiftPackageAssets", from: "1.0.0"),

// Add to a target
.target(
    name: "FeatureUI",
    dependencies: [
        .product(name: "PackageAssets", package: "SwiftPackageAssets")
    ]
)
```

## Examples

`Assets.swift`:

```swift
import PackageAssets

extension Assets.ImageResource {
    #ImageResource {
        .carrotFill
    }
}

extension Assets.ColorResource {
    #ColorResource(.public) {
        .carrotOrange;
        .Vegetable.carrot;
    }
}
```
