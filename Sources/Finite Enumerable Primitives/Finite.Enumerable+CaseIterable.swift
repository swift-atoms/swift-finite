// Finite.Enumerable+CaseIterable.swift
// Default Finite.Enumerable implementation for Swift.CaseIterable types
// whose AllCases is a RandomAccessCollection indexed by Int (the common
// enum case — synthesized [Self] allCases).

import Cardinal_Primitives
public import Finite_Primitive
import Ordinal_Primitives

// MARK: - CaseIterable-Default Bridge

/// Default `Finite.Enumerable` witness for conformers whose synthesized or
/// hand-written `AllCases` is `RandomAccessCollection` with `Int` indices.
///
/// This covers the common enum case: a Swift `enum` declared
/// `: CaseIterable` (or `: Finite.Enumerable` — which itself refines
/// `CaseIterable`) gets a synthesized `static let allCases: [Self]` whose
/// `AllCases == [Self]`, `AllCases.Index == Int`, and is
/// `RandomAccessCollection`. The defaults below derive `count`, `ordinal`,
/// and `init(_unchecked:ordinal:)` from `allCases`, eliminating the
/// per-conformer ceremony for enum types.
///
/// ## Activation rules
///
/// - `AllCases: RandomAccessCollection` — guarantees O(1) `firstIndex(of:)`
///   semantics aren't degraded (still O(n) on equality but on a contiguous
///   buffer) and O(1) subscript by integer index.
/// - `AllCases.Index == Int` — disambiguates from the in-package default
///   `Finite.Enumeration<Self>` (whose `Index == Index<Self>`, not `Int`),
///   so existing in-package conformers that rely on `Finite.Enumeration` as
///   `AllCases` are unaffected.
/// - `Self: Equatable` — required by `firstIndex(of:)`. `Finite.Enumerable`
///   does not require `Equatable` directly, but a `CaseIterable` enum is
///   `Equatable` by synthesis. Explicit Equatable conformers also activate
///   this path.
///
/// ## Shadowing
///
/// Conformers (e.g., `Bit`, `Tagged<Tag, Ordinal> where Tag: Finite.Capacity`,
/// `Interval.Bound`, `Comparison`) that provide their own `count`, `ordinal`, and
/// `init(_unchecked:ordinal:)` continue to shadow these defaults — Swift's
/// member lookup prefers the more-specific witness from the conformance
/// extension. The bridge activates only for conformers that do not supply
/// their own implementations.
///
/// ## Example
///
/// ```swift
/// enum Operation: Finite.Enumerable {
///     case add
///     case multiply
/// }
///
/// Operation.count            // 2 (from CaseIterable bridge)
/// Operation.add.ordinal      // 0 (from CaseIterable bridge)
/// Operation(0)               // .add (from Finite.Enumerable's init?(_:))
/// ```
extension Finite.Enumerable
where AllCases: RandomAccessCollection, AllCases.Index == Int, Self: Equatable {
    /// Number of distinct values, derived from `allCases.count`.
    @inlinable
    public static var count: Cardinal {
        Cardinal(UInt(Self.allCases.count))
    }

    /// Ordinal position of this value, derived from its index in `allCases`.
    ///
    /// `firstIndex(of:)` always succeeds for a `CaseIterable` type because
    /// every value of `Self` is present in `allCases`. The force-unwrap is
    /// load-bearing here: a `nil` return would indicate a structural violation
    /// of the `CaseIterable` contract (a value of `Self` not in `allCases`),
    /// which is a programmer error, not a recoverable condition.
    @inlinable
    public var ordinal: Ordinal_Primitives.Ordinal {
        // swift-format-ignore: NeverForceUnwrap
        let index = Self.allCases.firstIndex(of: self)!
        return Ordinal_Primitives.Ordinal(UInt(index))
    }

    /// Creates a value from its ordinal without bounds checking.
    ///
    /// The ordinal must be in `0..<count`. Out-of-bounds ordinals trap
    /// in the underlying `allCases` subscript — callers should prefer
    /// `init?(_:)` for untrusted input.
    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal_Primitives.Ordinal) {
        self = Self.allCases[Int(ordinal.rawValue)]
    }
}
