import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PackageAssetsMacros)
import PackageAssetsMacros

fileprivate let testMacros: [String: Macro.Type] = [
    "ColorResource": ColorResourceMacro.self,
]
#endif

final class ColorResourceMacroTests: XCTestCase {

    func testResultBuilderSingle() throws {
        assertMacroExpansion(
            """
            #ColorResource {
                .colorName
            }
            """,
            expandedSource: """
            public static let colorName = Assets.ColorResource(.colorName)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }
    
    func testResultBuilderMultiple() throws {
        assertMacroExpansion(
            """
            #ColorResource {
                .color1;
                .color2;
            }
            """,
            expandedSource: """
            public static let color1 = Assets.ColorResource(.color1)
            
            public static let color2 = Assets.ColorResource(.color2)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }

    func testResultBuilderEmpty() throws {
        assertMacroExpansion(
            """
            #ColorResource {
            }
            """,
            expandedSource: """
            """,
            diagnostics: [],
            macros: testMacros
        )
    }

    func testResultBuilderAccessLevelPublic() throws {
        assertMacroExpansion(
            """
            #ColorResource(.public) {
                .colorName
            }
            """,
            expandedSource: """
            public static let colorName = Assets.ColorResource(.colorName)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }

    func testResultBuilderAccessLevelPackage() throws {
        assertMacroExpansion(
            """
            #ColorResource(.package) {
                .colorName
            }
            """,
            expandedSource: """
            package static let colorName = Assets.ColorResource(.colorName)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }
    
    func testArraySingle() throws {
        assertMacroExpansion(
            """
            #ColorResource(resources: [
                .colorName
            ])
            """,
            expandedSource: """
            public static let colorName = Assets.ColorResource(.colorName)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }

    func testArrayMultiple() throws {
        assertMacroExpansion(
            """
            #ColorResource(resources: [
                .color1,
                .color2,
            ])
            """,
            expandedSource: """
            public static let color1 = Assets.ColorResource(.color1)
            
            public static let color2 = Assets.ColorResource(.color2)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }

    func testArrayEmpty() throws {
        assertMacroExpansion(
            """
            #ColorResource(resources: [
            ])
            """,
            expandedSource: """
            """,
            diagnostics: [],
            macros: testMacros
        )
    }
    
    func testArrayAccessLevelPublic() throws {
        assertMacroExpansion(
            """
            #ColorResource(.public, resources: [
                .colorName
            ])
            """,
            expandedSource: """
            public static let colorName = Assets.ColorResource(.colorName)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }

    func testArrayAccessLevelPackage() throws {
        assertMacroExpansion(
            """
            #ColorResource(.package, resources: [
                .colorName
            ])
            """,
            expandedSource: """
            package static let colorName = Assets.ColorResource(.colorName)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }
}
