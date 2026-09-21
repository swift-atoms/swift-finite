import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import Finite_Macro_Core

struct Derive: MemberMacro, ExtensionMacro {
    private static func isGeneric(_ declaration: some DeclGroupSyntax) -> Bool {
        declaration.as(StructDeclSyntax.self)?.genericParameterClause != nil
            || declaration.as(EnumDeclSyntax.self)?.genericParameterClause != nil
    }

    private static func hasNativeEnumeration(_ declaration: some DeclGroupSyntax) -> Bool {
        let inherited = declaration.inheritanceClause?.inheritedTypes.map { $0.type.trimmedDescription } ?? []
        return ["Enumerable", "CaseIterable"].allSatisfy { name in
            inherited.contains { $0 == name || $0.hasSuffix("." + name) }
        }
    }

    private static func inlineMembers(_ declaration: some DeclGroupSyntax) -> Bool {
        guard !isGeneric(declaration), hasNativeEnumeration(declaration) else { return false }
        // An ordinal initializer in a struct body suppresses Swift's synthesized
        // memberwise initializer. Generated Inputs already have explicit construction.
        return declaration.is(EnumDeclSyntax.self)
            || declaration.memberBlock.members.contains { $0.decl.is(InitializerDeclSyntax.self) }
    }

    static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard inlineMembers(declaration) else { return [] }
        return try Derivation.extensions(of: declaration, type: TypeSyntax(stringLiteral: "Self"))
            .flatMap { $0.memberBlock.members.map(\.decl) }
    }

    static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        // Native conformances are essential when this macro is itself attached
        // inside peer-macro output: Swift may not lower nested extension output.
        guard !inlineMembers(declaration) else { return [] }
        let inherited = declaration.inheritanceClause?.inheritedTypes.map { $0.type.trimmedDescription } ?? []
        return try Derivation.extensions(of: declaration, type: type).map { generated in
            var result = generated
            if var clause = result.inheritanceClause {
                let remaining = clause.inheritedTypes.filter { item in
                    let leaf = item.type.trimmedDescription.split(separator: ".").last!
                    return !inherited.contains { $0 == leaf || $0.hasSuffix("." + leaf) }
                }
                clause.inheritedTypes = InheritedTypeListSyntax(remaining.enumerated().map { index, item in
                    var item = item
                    item.trailingComma = index + 1 == remaining.count ? nil : .commaToken(trailingTrivia: .space)
                    return item
                })
                result.inheritanceClause = clause.inheritedTypes.isEmpty ? nil : clause
            }
            return result
        }
    }
}
