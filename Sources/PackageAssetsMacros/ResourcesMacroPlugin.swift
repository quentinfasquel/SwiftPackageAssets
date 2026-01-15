//
//  ResourcesMacroPlugin.swift
//  PublicResources
//
//  Created by Quentin Fasquel on 09/01/2026.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ResourcesMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ColorResourceMacro.self,
        ImageResourceMacro.self,
    ]
}
