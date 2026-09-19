import Type_Algebra_Syntax
public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    private struct Alternative {
        let name: String?
        let labels: [String?]
        let types: [String]
        var cardinality: String { "Finite::Finite.productCardinality([" + types.map { "\($0).count.rawValue" }.joined(separator: ", ") + "])" }
    }
    public static func extensions(of declaration: some DeclGroupSyntax, type: some TypeSyntaxProtocol) throws -> [ExtensionDeclSyntax] {
        let alternatives: [Alternative]
        let generics: [String]
        let name: String
        if let structure = declaration.as(StructDeclSyntax.self) {
            let properties = StoredProperties(structure, requiresMemberwise: true)
            guard properties.diagnostics.isEmpty else { throw AlgebraDiagnostic(properties.diagnostics.joined(separator: "; ")) }
            alternatives = [.init(name: nil, labels: properties.fields.map { $0.name }, types: properties.fields.map { $0.type.trimmedDescription })]
            generics = structure.genericParameterClause?.parameters.map(\.name.text) ?? []
            name = structure.name.text
        } else if let enumeration = declaration.as(EnumDeclSyntax.self) {
            guard enumeration.inheritanceClause?.inheritedTypes.allSatisfy({ !["String", "Int", "UInt", "~Copyable", "~Escapable"].contains($0.type.trimmedDescription) }) ?? true else {
                throw AlgebraDiagnostic("@Finite requires a Copyable, Escapable sum without raw values")
            }
            alternatives = RecursiveShape.elements(of: enumeration).map { item in
                .init(name: item.name.text, labels: RecursiveShape.parameters(of: item).map { RecursiveShape.label(of: $0) },
                    types: RecursiveShape.parameters(of: item).map { $0.type.trimmedDescription })
            }
            generics = enumeration.genericParameterClause?.parameters.map(\.name.text) ?? []
            name = enumeration.name.text
        } else { throw AlgebraDiagnostic("@Finite applies to structs and enums") }
        for payload in alternatives.flatMap(\.types) {
            if payload.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "_" }).contains(where: { $0 == name || $0 == "Self" }) {
                throw AlgebraDiagnostic("@Finite does not derive cardinality for recursive types")
            }
        }
        let requirements = generics.map { "\($0): Finite::Finite.Enumerable" }
        let whereClause = requirements.isEmpty ? "" : " where " + requirements.joined(separator: ", ")
        let access = RecursiveShape.access(of: declaration)
        let cardinalities = alternatives.map(\.cardinality)
        let count = "Finite::Finite.sumCardinality([\(cardinalities.joined(separator: ", "))])"
        var ranks: [String] = []
        var unrank: [String] = []
        for (index, alternative) in alternatives.enumerated() {
            let prefix = "Finite::Finite.sumCardinality([\(cardinalities.prefix(index).joined(separator: ", "))])"
            let variables = alternative.types.indices.map { "value\($0)" }
            let values = alternative.name == nil ? alternative.labels.map { "self.\($0!)" } : variables
            let rank = values.enumerated().reduce("UInt(0)") { accumulated, pair in
                "(\(accumulated) * \(alternative.types[pair.offset]).count.rawValue + \(pair.element).ordinal.rawValue)"
            }
            let result = "return Ordinal::Ordinal(\(prefix) + \(rank))"
            if let name = alternative.name {
                let pattern = variables.isEmpty ? ".\(name)" : "let .\(name)(\(variables.joined(separator: ", ")))"
                ranks.append("case \(pattern): \(result)")
            } else { ranks.append(result) }
            var build = ""
            for j in alternative.types.indices.reversed() {
                let fieldType = alternative.types[j]
                build += "let value\(j) = \(fieldType)(_unchecked: (), ordinal: Ordinal::Ordinal(remainder % \(fieldType).count.rawValue))\n"
                build += "remainder /= \(fieldType).count.rawValue\n"
            }
            let arguments = variables.enumerated().map { j, value in (alternative.labels[j].map { "\($0): " } ?? "") + value }.joined(separator: ", ")
            let constructor = alternative.name.map { ".\($0)" + (variables.isEmpty ? "" : "(\(arguments))") } ?? "Self(\(arguments))"
            unrank.append("""
                if remaining < \(alternative.cardinality) {
                    \(alternative.types.isEmpty ? "" : "var remainder = remaining")
                    \(build)
                    self = \(constructor)
                    return
                }
                remaining -= \(alternative.cardinality)
                """)
        }
        let rankBody = declaration.is(EnumDeclSyntax.self) ? "switch self {\n\(ranks.joined(separator: "\n"))\n}" : ranks.joined(separator: "\n")
        return [try ExtensionDeclSyntax("""
            extension \(type): Finite::Finite.Enumerable, Swift.CaseIterable, Swift.Sendable\(raw: whereClause) {
                \(raw: access)typealias AllCases = Finite::Finite.Enumeration<Self>
                \(raw: access)static var count: Cardinal::Cardinal { Cardinal::Cardinal(\(raw: count)) }
                \(raw: access)var ordinal: Ordinal::Ordinal { \(raw: rankBody) }
                \(raw: access)init(_unchecked: Void, ordinal: Ordinal::Ordinal) {
                    precondition(ordinal.rawValue < Self.count.rawValue, "Finite ordinal is out of range")
                    \(raw: alternatives.isEmpty ? "" : "var remaining = ordinal.rawValue")
                    \(raw: unrank.joined(separator: "\n"))
                    preconditionFailure("No finite constructor for ordinal")
                }
            }
            """)]
    }
}
