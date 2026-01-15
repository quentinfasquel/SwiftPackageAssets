import SwiftSyntax
import SwiftSyntaxMacros

public struct ColorResourceMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        try ResourcesMacro.expansion(
            resourceType: .colorResource,
            of: node,
            in: context
        )
    }
}
