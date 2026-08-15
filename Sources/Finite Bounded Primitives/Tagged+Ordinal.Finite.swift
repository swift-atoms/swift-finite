// Tagged+Ordinal.Finite.swift
// Bounded ordinal extensions on Tagged.

import Finite_Capacity_Primitives
public import Finite_Primitive
import Ordinal_Primitives
import Tagged_Primitives

// MARK: - Construction

extension Tagged where Tag: ~Copyable & ~Escapable {
    /// Creates a bounded ordinal from a position, returning nil if out of bounds.
    @inlinable
    public init?<let N: Int>(_ position: Ordinal)
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        guard position < Finite.Bound<N>.capacity else { return nil }
        self.init(_unchecked: position)
    }

    /// Creates a bounded ordinal from an integer, returning nil if out of bounds.
    @inlinable
    public init?<let N: Int>(_ value: Int)
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        guard value >= 0, value < N else { return nil }
        self.init(_unchecked: value)
    }

    /// Creates a bounded ordinal without bounds checking.
    ///
    /// - Parameter value: Must be in `0..<N`.
    /// - Warning: No validation is performed. Use only when the value
    ///   is known to be in bounds.
    @inlinable
    public init<let N: Int>(_unchecked value: Int)
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        self.init(_unchecked: Ordinal(UInt(value)))
    }
}

// MARK: - Bounds

extension Tagged where Tag: ~Copyable & ~Escapable {
    /// The capacity (number of valid values).
    @inlinable
    public static func capacity<let N: Int>() -> Cardinal
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        Finite.Bound<N>.capacity
    }

    /// The maximum valid position (N - 1), or nil if N == 0.
    @inlinable
    public static func max<let N: Int>() -> Self?
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        guard N > 0 else { return nil }
        return Self(_unchecked: N - 1)
    }
}

// MARK: - Successor / Predecessor

extension Tagged where Tag: ~Copyable & ~Escapable {
    /// The next position, or nil if at maximum.
    @inlinable
    public func successor<let N: Int>() -> Self?
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        let next = underlying + Cardinal.one
        guard next < Finite.Bound<N>.capacity else { return nil }
        return Self(_unchecked: next)
    }

    /// The previous position, or nil if at zero.
    @inlinable
    public func predecessor<let N: Int>() -> Self?
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        let previous: Ordinal
        do throws(Ordinal.Error) {
            previous = try underlying.predecessor.exact()
        } catch {
            return nil
        }
        return Self(_unchecked: previous)
    }
}

// MARK: - Offset

extension Tagged where Tag: ~Copyable & ~Escapable {
    /// Returns a position offset by delta, or nil if out of bounds.
    @inlinable
    public func offset<let N: Int>(by delta: Int) -> Self?
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        let current = Int(bitPattern: self)
        let result = current + delta
        guard result >= 0, result < N else { return nil }
        return Self(_unchecked: result)
    }

    /// Returns a position offset by delta, clamped to valid bounds.
    @inlinable
    public func clamped<let N: Int>(offsetBy delta: Int) -> Self
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        let current = Int(bitPattern: self)
        let result = current + delta
        if result < 0 { return Self(_unchecked: .zero) }
        if result >= N { return Self(_unchecked: N - 1) }
        return Self(_unchecked: result)
    }
}

// MARK: - Distance

extension Tagged where Tag: ~Copyable & ~Escapable {
    /// The signed distance from this position to another.
    @inlinable
    public func distance<let N: Int>(to other: Self) -> Int
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        let otherPosition = Int(bitPattern: other)
        let selfPosition = Int(bitPattern: self)
        return otherPosition - selfPosition
    }
}

// MARK: - Complement

extension Tagged where Tag: ~Copyable & ~Escapable {
    /// The complement: position N - 1 - self.
    ///
    /// Maps 0 → max, 1 → max-1, etc. For `Ordinal.Finite<3>`:
    /// - 0 → 2
    /// - 1 → 1
    /// - 2 → 0
    @inlinable
    public func complement<let N: Int>() -> Self
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        Self(_unchecked: N - 1 - Int(bitPattern: self))
    }
}

// MARK: - Injection / Projection

extension Tagged where Tag: ~Copyable & ~Escapable {
    /// Injects into a larger bounded ordinal.
    ///
    /// Safe upcast: any value valid for N is valid for M where M >= N.
    @inlinable
    public func injected<let N: Int, let M: Int>() -> Tagged<Finite.Bound<M>, Ordinal>
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        Tagged<Finite.Bound<M>, Ordinal>(_unchecked: underlying)
    }

    /// Projects into a smaller bounded ordinal.
    ///
    /// Returns nil if the current value exceeds M - 1.
    @inlinable
    public func projected<let N: Int, let M: Int>() -> Tagged<Finite.Bound<M>, Ordinal>?
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        guard underlying < Finite.Bound<M>.capacity else { return nil }
        return Tagged<Finite.Bound<M>, Ordinal>(_unchecked: underlying)
    }
}

// MARK: - Product Isomorphism (Fin (m×n) ≅ Fin m × Fin n)

extension Tagged where Tag: ~Copyable & ~Escapable {
    /// Decomposes this ordinal into row and column coordinates.
    ///
    /// Interprets `self` as a row-major index in a grid with `Columns` columns:
    /// - row = `position / Columns`
    /// - column = `position % Columns`
    ///
    /// ## Example
    ///
    /// ```swift
    /// // 3×4 grid, index 7 → row 1, column 3
    /// let index: Ordinal.Finite<12> = Ordinal.Finite(7)!
    /// let (row, column) = index.decomposed(rows: 3, columns: 4)!
    /// // row == 1, column == 3
    /// ```
    ///
    /// - Returns: `(row, column)`, or `nil` if `Rows × Columns ≠ N`.
    @inlinable
    public func decomposed<let N: Int, let Rows: Int, let Columns: Int>()
        -> (
            row: Tagged<Finite.Bound<Rows>, Ordinal>, column: Tagged<Finite.Bound<Columns>, Ordinal>
        )?
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        guard Rows * Columns == N else { return nil }
        let position = Int(bitPattern: self)
        let row = position / Columns
        let column = position % Columns
        return (
            Tagged<Finite.Bound<Rows>, Ordinal>(_unchecked: row),
            Tagged<Finite.Bound<Columns>, Ordinal>(_unchecked: column)
        )
    }

    /// Creates an ordinal from row and column indices (row-major linear index).
    ///
    /// Computes the row-major linear index: `row × Columns + column`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // 3×4 grid, row 1, column 3 → index 7
    /// let row: Ordinal.Finite<3> = Ordinal.Finite(1)!
    /// let column: Ordinal.Finite<4> = Ordinal.Finite(3)!
    /// let index: Ordinal.Finite<12> = .composed(row: row, column: column)!
    /// // index == 7
    /// ```
    ///
    /// - Returns: The combined ordinal, or `nil` if `Rows × Columns ≠ N`.
    @inlinable
    public static func composed<let N: Int, let Rows: Int, let Columns: Int>(
        row: Tagged<Finite.Bound<Rows>, Ordinal>,
        column: Tagged<Finite.Bound<Columns>, Ordinal>
    ) -> Self?
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        guard Rows * Columns == N else { return nil }
        let rowPosition = Int(bitPattern: row)
        let columnPosition = Int(bitPattern: column)
        let position = rowPosition * Columns + columnPosition
        return Self(_unchecked: position)
    }
}
