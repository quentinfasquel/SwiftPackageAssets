import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PackageAssetsMacros)
import PackageAssetsMacros

fileprivate let testMacros: [String: Macro.Type] = [
    "ImageResource": ImageResourceMacro.self,
]
#endif

final class ImageResourceMacroTests: XCTestCase {

    func testResultBuilderSingle() throws {
        assertMacroExpansion(
            """
            #ImageResource {
                .image1
            }
            """,
            expandedSource: """
            public static let image1 = Assets.ImageResource(.image1)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }

    func testResultBuilder() throws {
        assertMacroExpansion(
            """
            #ImageResource {
                .image1;
                .image2;
            }
            """,
            expandedSource: """
            public static let image1 = Assets.ImageResource(.image1)
            
            public static let image2 = Assets.ImageResource(.image2)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }

    func testResultBuilderEmpty() throws {
        assertMacroExpansion(
            """
            #ImageResource {
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
            #ImageResource(.public) {
                .imageName
            }
            """,
            expandedSource: """
            public static let imageName = Assets.ImageResource(.imageName)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }

    func testResultBuilderAccessLevelPackage() throws {
        assertMacroExpansion(
            """
            #ImageResource(.package) {
                .imageName
            }
            """,
            expandedSource: """
            package static let imageName = Assets.ImageResource(.imageName)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }
    
    
    func testArraySingle() throws {
        assertMacroExpansion(
            """
            #ImageResource(resources: [
                .image1
            ])
            """,
            expandedSource: """
            public static let image1 = Assets.ImageResource(.image1)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }

    func testArrayMultiple() throws {
        assertMacroExpansion(
            """
            #ImageResource(resources: [
                .image1,
                .image2,
            ])
            """,
            expandedSource: """
            public static let image1 = Assets.ImageResource(.image1)
            
            public static let image2 = Assets.ImageResource(.image2)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }
    
    func testArrayEmpty() throws {
        assertMacroExpansion(
            """
            #ImageResource(resources: [
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
            #ImageResource(.public, resources: [
                .imageName
            ])
            """,
            expandedSource: """
            public static let imageName = Assets.ImageResource(.imageName)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }

    func testArrayAccessLevelPackage() throws {
        assertMacroExpansion(
            """
            #ImageResource(.package, resources: [
                .imageName
            ])
            """,
            expandedSource: """
            package static let imageName = Assets.ImageResource(.imageName)
            """,
            diagnostics: [],
            macros: testMacros
        )
    }
}
