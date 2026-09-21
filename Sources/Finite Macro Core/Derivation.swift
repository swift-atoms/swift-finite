import Type_Algebra_Syntax
public import SwiftSyntax
import SwiftSyntaxBuilder

public enum Derivation {
    private struct Alternative {
        let name: String?
        let labels: [String?]
        let types: [String]
        var cardinality: String { types.isEmpty ? "Swift.UInt(1)" : "Finite::Finite.productCardinality([" + types.map { "\($0).count.rawValue" }.joined(separator: ", ") + "])" }
    }
    // Construction must be a bijection with the stored coordinates. Accept the
    // synthesized initializer or an explicit, effect-free fieldwise initializer.
    private static func constructionLabels(_ structure: StructDeclSyntax,
        properties: Type.Syntax.Properties) throws -> [String?] {
        guard !properties.fields.contains(where: { !$0.isMutable && $0.defaultValue != nil }) else {
            throw Type.Failure("@Finite cannot enumerate initialized constant fields")
        }
        guard properties.hasCustomInitializer else { return properties.fields.map { $0.name } }
        for member in structure.memberBlock.members {
            guard let initializer = member.decl.as(InitializerDeclSyntax.self),
                initializer.optionalMark == nil, initializer.genericParameterClause == nil,
                initializer.genericWhereClause == nil, initializer.signature.effectSpecifiers == nil,
                initializer.attributes.isEmpty,
                let body = initializer.body else { continue }
            let parameters = Array(initializer.signature.parameterClause.parameters)
            guard parameters.count == properties.fields.count,
                body.statements.count == properties.fields.count else { continue }
            let matches = zip(zip(properties.fields, parameters), body.statements).allSatisfy { pair, statement in
                let (field, parameter) = pair
                let local = parameter.secondName ?? parameter.firstName
                return parameter.type.trimmedDescription == field.type.trimmedDescription
                    && parameter.attributes.isEmpty && parameter.modifiers.isEmpty
                    && parameter.ellipsis == nil
                    && statement.tokens(viewMode: .sourceAccurate).map(\.text)
                        == ["self", ".", field.name, "=", local.text]
            }
            if matches {
                return parameters.map { $0.firstName.text == "_" ? nil : $0.firstName.text }
            }
        }
        throw Type.Failure("@Finite requires synthesized or direct fieldwise construction; validating or normalizing initializers need an explicit finite witness")
    }
    public static func extensions(of declaration: some DeclGroupSyntax, type: some TypeSyntaxProtocol) throws -> [ExtensionDeclSyntax] {
        let alternatives: [Alternative]
        let generics: [String]
        let name: String
        if let structure = declaration.as(StructDeclSyntax.self) {
            let properties = Type.Syntax.Properties(structure)
            guard properties.diagnostics.isEmpty else { throw Type.Failure(properties.diagnostics.joined(separator: "; ")) }
            let labels = try constructionLabels(structure, properties: properties)
            alternatives = [.init(name: nil, labels: labels, types: properties.fields.map { $0.type.trimmedDescription })]
            generics = structure.genericParameterClause?.parameters.map(\.name.text) ?? []
            name = structure.name.text
        } else if let enumeration = declaration.as(EnumDeclSyntax.self) {
            guard enumeration.inheritanceClause?.inheritedTypes.allSatisfy({ !["String", "Int", "UInt", "~Copyable", "~Escapable"].contains($0.type.trimmedDescription) }) ?? true else {
                throw Type.Failure("@Finite requires a Copyable, Escapable sum without raw values")
            }
            alternatives = Type.Syntax.Recursion.elements(of: enumeration).map { item in
                .init(name: item.name.text, labels: Type.Syntax.Recursion.parameters(of: item).map { Type.Syntax.Recursion.label(of: $0) },
                    types: Type.Syntax.Recursion.parameters(of: item).map { $0.type.trimmedDescription })
            }
            generics = enumeration.genericParameterClause?.parameters.map(\.name.text) ?? []
            name = enumeration.name.text
        } else { throw Type.Failure("@Finite applies to structs and enums") }
        for payload in alternatives.flatMap(\.types) {
            if payload.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "_" }).contains(where: { $0 == name || $0 == "Self" }) {
                throw Type.Failure("@Finite does not derive cardinality for recursive types")
            }
        }
        let components = alternatives.flatMap(\.types).filter { spelling in
            spelling.split(whereSeparator: { !$0.isLetter && !$0.isNumber && $0 != "_" })
                .contains { generics.contains(String($0)) }
        }
        let requirements = Array(Set(components)).sorted().map { "\($0): Finite::Finite.Enumerable" }
        let whereClause = requirements.isEmpty ? "" : " where " + requirements.joined(separator: ", ")
        let access = Type.Syntax.Recursion.access(of: declaration)
        let cardinalities = alternatives.map(\.cardinality)
        let isEnumeration = declaration.is(EnumDeclSyntax.self)
        let isNullarySum = isEnumeration && alternatives.allSatisfy { $0.types.isEmpty }
        // Resolve unit sums and singleton sums while generating code. In
        // particular, field-index enums need no runtime cardinal arithmetic.
        let count = isNullarySum ? "Swift.UInt(\(alternatives.count))"
            : cardinalities.count == 1 ? cardinalities[0]
            : "Finite::Finite.sumCardinality([\(cardinalities.joined(separator: ", "))])"
        var ranks: [String] = []
        var unrank: [String] = []
        for (index, alternative) in alternatives.enumerated() {
            let prefix = isNullarySum || index == 0 ? "Swift.UInt(\(index))"
                : "Finite::Finite.sumCardinality([\(cardinalities.prefix(index).joined(separator: ", "))])"
            let variables = alternative.types.indices.map { "value\($0)" }
            let values = alternative.name == nil
                ? Type.Syntax.Properties(declaration.as(StructDeclSyntax.self)!).fields.map { "self.\($0.name)" }
                : variables
            // Keep syntax depth constant for wide products. Nested Horner
            // expressions can exhaust the parser before a macro is typechecked.
            let steps = values.enumerated().map { pair in
                "rank = rank * \(alternative.types[pair.offset]).count.rawValue + \(pair.element).ordinal.rawValue"
            }.joined(separator: "\n")
            let result = values.isEmpty
                ? "return Ordinal::Ordinal(\(prefix))"
                : "var rank: Swift.UInt = 0\n\(steps)\nreturn Ordinal::Ordinal(\(prefix) + rank)"
            if let name = alternative.name {
                let pattern = variables.isEmpty ? ".\(name)" : "let .\(name)(\(variables.joined(separator: ", ")))"
                ranks.append("case \(pattern): \(result)")
            } else { ranks.append(result) }
            var build = ""
            for j in alternative.types.indices.reversed() {
                let fieldType = alternative.types[j]
                build += "let value\(j): \(fieldType) = \(fieldType)(_unchecked: (), ordinal: Ordinal::Ordinal(remainder % \(fieldType).count.rawValue))\n"
                build += "remainder /= \(fieldType).count.rawValue\n"
            }
            let arguments = variables.enumerated().map { j, value in (alternative.labels[j].map { "\($0): " } ?? "") + value }.joined(separator: ", ")
            let constructor = alternative.name.map { ".\($0)" + (variables.isEmpty ? "" : "(\(arguments))") } ?? "Self(\(arguments))"
            if !isEnumeration {
                unrank.append("""
                    \(alternative.types.isEmpty ? "" : "var remainder: Swift.UInt = ordinal.rawValue")
                    \(build)
                    self = \(constructor)
                    """)
                continue
            }
            unrank.append("""
                if remaining < \(alternative.cardinality) {
                    \(alternative.types.isEmpty ? "" : "var remainder: Swift.UInt = remaining")
                    \(build)
                    self = \(constructor)
                    return
                }
                remaining -= \(alternative.cardinality)
                """)
        }
        let rankBody = isEnumeration ? "switch self {\n\(ranks.joined(separator: "\n"))\n}" : ranks.joined(separator: "\n")
        let unrankBody: String
        if isNullarySum {
            let cases = alternatives.enumerated().map { index, alternative in
                "case \(index): self = .\(alternative.name!)"
            }.joined(separator: "\n")
            unrankBody = "switch ordinal.rawValue {\n\(cases)\ndefault: preconditionFailure(\"No finite constructor for ordinal\")\n}"
        } else if isEnumeration {
            unrankBody = "var remaining: Swift.UInt = ordinal.rawValue\n" + unrank.joined(separator: "\n")
                + "\npreconditionFailure(\"No finite constructor for ordinal\")"
        } else {
            unrankBody = unrank.joined(separator: "\n")
        }
        return [try ExtensionDeclSyntax("""
            extension \(type): Finite::Finite.Enumerable, Swift.CaseIterable\(raw: whereClause) {
                \(raw: access)typealias AllCases = Finite::Finite.Enumeration<Self>
                \(raw: access)static var count: Cardinal::Cardinal { Cardinal::Cardinal(\(raw: count)) }
                \(raw: access)var ordinal: Ordinal::Ordinal { \(raw: rankBody) }
                \(raw: access)init(_unchecked: Void, ordinal: Ordinal::Ordinal) {
                    precondition(ordinal.rawValue < Self.count.rawValue, "Finite ordinal is out of range")
                    \(raw: unrankBody)
                }
            }
            """)]
    }
}
