import ExportingClient
import SwiftUI

let color0 = Color(.carrotOrange)
let color1 = Color(.Vegetable.carrot)
let image = Image(.carrotFill)

#if canImport(AppKit)
let nsColor0 = NSColor(resource: .carrotOrange)
let nsColor1 = NSColor(resource: .Vegetable.carrot)
let nsImage = NSImage(resource: .carrotFill)
#elseif canImport(UIKit)
let uiColor0 = UIColor(resource: .carrotOrange)
let uiColor1 = UIColor(resource: .Vegetable.orange)
let uiImage = UIImage(resource: .carrotFill)
#endif
