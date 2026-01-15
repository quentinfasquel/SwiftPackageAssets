//
//  ResourceMacro.swift
//  SwiftPackageAssets
//
//  Created by Quentin Fasquel on 12/01/2026.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

import DeveloperToolsSupport

enum ResourceType: String, CustomStringConvertible {    
    case colorResource
    case imageResource

    var description: String {
        // ColorResource / ImageResource
        rawValue.prefix(1).capitalized.appending(rawValue.dropFirst())
    }
}

struct ResourcesMacro {
    
    private struct ResourcePath {
        let segments: [String]
        var namespaceSegments: [String] { Array(segments.dropLast()) }
        var leaf: String { segments.last ?? "" }
    }
    
    private class NamespaceNode {
        var children: [String: NamespaceNode] = [:]
        var leaves: [String] = []
        
        func ensureChild(_ name: String) -> NamespaceNode {
            if let child = children[name] {
                return child
            }
            let newChild = NamespaceNode()
            children[name] = newChild
            return newChild
        }
    }
    
    private static func parsePath(from memberAccess: MemberAccessExprSyntax) -> ResourcePath? {
        var segments: [String] = []
        var current: ExprSyntax = ExprSyntax(memberAccess)
        
        while let m = current.as(MemberAccessExprSyntax.self) {
            let segment = m.declName.baseName.text
            segments.append(segment)
            if let base = m.base {
                current = base
            } else {
                break
            }
        }
        guard !segments.isEmpty else { return nil }
        // The segments were collected right-to-left, reverse for left-to-right
        return ResourcePath(segments: segments.reversed())
    }
    
    private static func buildTree(from paths: [ResourcePath]) -> NamespaceNode {
        let root = NamespaceNode()
        for path in paths {
            var node = root
            for segment in path.namespaceSegments {
                node = node.ensureChild(segment)
            }
            node.leaves.append(path.leaf)
        }
        return root
    }
    
    private static func emitNamespaceBody(accessLevel: String, resourceType: ResourceType, node: NamespaceNode, pathSegments: [String]) -> [DeclSyntax] {
        var decls: [DeclSyntax] = []
        
        for leaf in node.leaves.sorted() {
            let fullPath = (pathSegments + [leaf]).joined(separator: ".")
            let prop: DeclSyntax = """
            \(raw: accessLevel) static let \(raw: leaf) = Assets.\(raw: resourceType)(.\(raw: fullPath))
            """
            decls.append(prop)
        }
        
        for (name, child) in node.children.sorted(by: { $0.key < $1.key }) {
            let childBody = emitNamespaceBody(accessLevel: accessLevel, resourceType: resourceType, node: child, pathSegments: pathSegments + [name])
            let enumDecl: DeclSyntax = """
            \(raw: accessLevel) enum \(raw: name) {
                  \(raw: childBody.map { $0.description }.joined(separator: "\n\n"))
                }
            """
            decls.append(enumDecl)
        }
        
        return decls
    }
    
    static func expansion(
        resourceType: ResourceType,
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let accessLevel: String
        let imageResources: [MemberAccessExprSyntax]
        switch node.arguments.count {
        case 0:
            accessLevel = "\(ResourcesMacro.publicAccess)"
            imageResources = try ResourcesMacro._resources(from: node.trailingClosure)
        case 1:
            if let trailingClosure = node.trailingClosure {
                accessLevel = try ResourcesMacro.accessControl(from: node.arguments.first)
                imageResources = try ResourcesMacro._resources(from: trailingClosure)
            } else {
                accessLevel = "\(ResourcesMacro.publicAccess)"
                imageResources = try ResourcesMacro._resources(from: node.arguments.first)
            }
        case 2:
            accessLevel = try ResourcesMacro.accessControl(from: node.arguments.first)
            imageResources = try ResourcesMacro._resources(from: node.arguments.last)
        default:
            return []
        }

        let paths = try imageResources.map { member -> ResourcePath in
            guard let path = parsePath(from: member) else {
                throw DiagnosticsError(node: Syntax(member), message: .cannotFindResource)
            }
            return path
        }
        
        let tree = buildTree(from: paths)
        let bodyDecls = emitNamespaceBody(accessLevel: accessLevel, resourceType: resourceType, node: tree, pathSegments: [])
        
        let res: DeclSyntax = """
            \(raw: bodyDecls.map { $0.description }.joined(separator: "\n\n"))
        """
        
        return [res]
    }
    
    // MARK: -
    
    static let packageAccess: String = "package"
    static let publicAccess: String = "public"
    
    static func accessControl(from arg: LabeledExprListSyntax.Element?) throws -> String {
        guard let accessLevel = arg?.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text else {
            if let arg {
                throw DiagnosticsError(node: Syntax(arg), message: .cannotParseAccessLevel)
            } else {
                return ""
            }
        }
        return accessLevel
    }

    static func _resources(from arg: LabeledExprListSyntax.Element?) throws -> [MemberAccessExprSyntax] {
        if let arrayExprSyntax = arg?.expression.as(ArrayExprSyntax.self) {
            try _resources(from: arrayExprSyntax)
        } else if let closureExprSyntax = arg?.expression.as(ClosureExprSyntax.self) {
            try _resources(from: closureExprSyntax)
        } else {
            []
        }
    }

    static func _resources(from arrayExprSyntax: ArrayExprSyntax) throws -> [MemberAccessExprSyntax] {
        let elements = arrayExprSyntax.elements

        return try elements.map { element in
            // Each array element should be a member access expression like `.myImage`
            if let member = element.expression.as(MemberAccessExprSyntax.self) {
                return member
            } else {
                throw DiagnosticsError(node: Syntax(element), message: .cannotFindResource)
            }
        }
    }

    static func _resources(from closureExprSyntax: ClosureExprSyntax?) throws -> [MemberAccessExprSyntax] {
        guard let closureExprSyntax else { return [] }
        return try closureExprSyntax.statements.map {
            if let member = $0.item.as(MemberAccessExprSyntax.self) {
                return member
            } else {
                throw DiagnosticsError(node: Syntax($0.item), message: .cannotFindResource)
            }
        }
    }
    
    
    enum Diagnostic: DiagnosticMessage {
       case cannotFindResource
       case cannotParseAccessLevel

       var severity: DiagnosticSeverity { .error }

       var message: String {
           switch self {
           case .cannotFindResource:
               "Cannot find Image Resources"
           case .cannotParseAccessLevel:
               "Cannot parse access level"
           }
       }

       var diagnosticID: MessageID { .init(domain: "SFSymbolMacro", id: self.message) }
    }
}


extension DiagnosticsError {
    fileprivate init(node: Syntax, message: ResourcesMacro.Diagnostic) {
       self.init(diagnostics: [
           .init(node: node, message: message)
       ])
   }
}

extension ArrayElementSyntax {
    fileprivate func contentText() -> MemberAccessExprSyntax? {
        expression.as(MemberAccessExprSyntax.self)
    }
}

