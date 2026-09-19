import SwiftSyntax
import SwiftSyntaxMacros
import Finite_Macro_Core
struct Derive: ExtensionMacro {
    static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
        try Derivation.extensions(of: declaration, type: type)
    }
}
