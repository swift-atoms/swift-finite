# swift-finite

Use this package when a type has finitely many values and you want to number them, enumerate them all, or move between a value and its position. Attach `@Finite` from the `Finite Macro` product to a struct or enum whose stored parts are finite, or conform by hand to `Finite.Enumerable`. For a position bounded by a compile-time size, use `Ordinal.Finite<N>`. For a position with no upper bound, use `Ordinal` from swift-ordinal.

## Laws

- A finite type numbers its values from zero up to its count, one ordinal per value, and turning an ordinal back into a value gives the same value.
- `@Finite` numbers a struct's values like the digits of a number in declaration order: the first stored field is the most significant and the last changes fastest. An enum's cases follow in declaration order, each case's values after all values of the cases before it.
- `Optional` puts nil first and then the wrapped values. `Bool` puts false before true. `Polarity` puts positive before negative.
- Reordering fields or cases changes the ordinals, so ordinals are not stable identifiers across versions of a type.
- `Finite.Enumerable.allCases` builds each value from its ordinal when it is read. It never stores all values.
- Counting traps rather than wraps when a count does not fit in a `UInt`. A product with a zero factor counts zero even when the other factors would overflow.
- `@Finite` refuses recursive types, enums with raw values or without `Copyable`, and structs with a constant field that has a default value. A struct must have the synthesized memberwise initializer or one that assigns each parameter straight to its field. A type that validates or normalizes in its initializer needs a hand-written conformance.
- A generic parameter must be `Finite.Enumerable` only when a stored field's type mentions it. A phantom parameter needs nothing.
- A type that is `CaseIterable` and `Equatable`, with an `Int`-indexed random-access `allCases`, takes its count and ordinals from `allCases`. Finding a value's ordinal then searches `allCases` in order.
- `Ordinal.Finite<N>` has no values when N is zero or negative. Its failable initializers return nil outside zero up to N. Its unchecked initializers and integer literals trap instead.
- `Ordinal.Finite.successor()` and `Ordinal.Finite.predecessor()` return nil past either end, and so does `Ordinal.Finite.offset(by:)`. `Ordinal.Finite.clamped(offsetBy:)` stops at the first or last position.
- `Ordinal.Finite.injected()` traps when the destination is smaller than the source. `Ordinal.Finite.projected()` returns nil when the position does not fit.
- `Ordinal.Finite.decomposed()` and `Ordinal.Finite.composed(row:column:)` use row-major order and return nil unless rows times columns equals N.
