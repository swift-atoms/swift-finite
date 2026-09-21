import Finite_Macro_Core
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import Testing

@Test(arguments: [
    "struct Invalid { let value: Bool; init(value: Bool) { self.value = !value } }",
    "struct Invalid { let value: Bool; init(value: Bool) { precondition(value); self.value = value } }",
    "struct Invalid { let value: Bool = true }",
    "indirect enum Invalid { case next(Invalid) }",
])
func rejectsStructuresWithoutTheRequiredFiniteConstruction(source: String) throws {
    let declaration = try #require(Parser.parse(source: source).statements.first?.item.as(DeclSyntax.self))
    #expect(throws: (any Error).self) {
        if let structure = declaration.as(StructDeclSyntax.self) {
            _ = try Derivation.extensions(of: structure, type: TypeSyntax(stringLiteral: "Invalid"))
        } else {
            _ = try Derivation.extensions(of: declaration.cast(EnumDeclSyntax.self), type: TypeSyntax(stringLiteral: "Invalid"))
        }
    }
}
