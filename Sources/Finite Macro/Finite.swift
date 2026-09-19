@_exported import Finite
@_exported import Cardinal
@_exported import Ordinal
/// Finite sums/products with checked cardinal arithmetic and declaration-order mixed-radix enumeration.
@attached(extension, conformances: Finite::Finite.Enumerable, Swift.CaseIterable, Swift.Sendable, names: named(AllCases), named(count), named(ordinal), named(init))
public macro Finite() = #externalMacro(module: "Finite_Macro_Plugin", type: "Derive")
