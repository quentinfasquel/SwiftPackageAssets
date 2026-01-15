import SwiftSyntax
import SwiftSyntaxMacros

public struct ImageResourceMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try ResourcesMacro.expansion(
            resourceType: .imageResource,
            of: node,
            in: context
        )
    }
}
