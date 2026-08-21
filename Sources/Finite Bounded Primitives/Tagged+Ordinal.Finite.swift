import Finite_Capacity_Primitives
public import Finite_Primitive
import Ordinal_Primitives
import Tagged_Primitives

extension Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public init?<let N: Int>(_ position: Ordinal)
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        guard position < Finite.Bound<N>.capacity else { return nil }
        self.init(_unchecked: position)
    }

    @inlinable
    public init?<let N: Int>(_ value: Int)
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        guard value >= 0, value < N else { return nil }
        self.init(_unchecked: value)
    }

    @inlinable
    public init<let N: Int>(_unchecked value: Int)
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        self.init(_unchecked: Ordinal(UInt(value)))
    }
}

extension Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public static func capacity<let N: Int>() -> Cardinal
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        Finite.Bound<N>.capacity
    }

    @inlinable
    public static func max<let N: Int>() -> Self?
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        guard N > 0 else { return nil }
        return Self(_unchecked: N - 1)
    }
}

extension Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public func successor<let N: Int>() -> Self?
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        let next = underlying + Cardinal.one
        guard next < Finite.Bound<N>.capacity else { return nil }
        return Self(_unchecked: next)
    }

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

extension Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public func offset<let N: Int>(by delta: Int) -> Self?
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        let current = Int(bitPattern: self)
        let result = current + delta
        guard result >= 0, result < N else { return nil }
        return Self(_unchecked: result)
    }

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

extension Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public func distance<let N: Int>(to other: Self) -> Int
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        let otherPosition = Int(bitPattern: other)
        let selfPosition = Int(bitPattern: self)
        return otherPosition - selfPosition
    }
}

extension Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public func complement<let N: Int>() -> Self
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        Self(_unchecked: N - 1 - Int(bitPattern: self))
    }
}

extension Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public func injected<let N: Int, let M: Int>() -> Tagged<Finite.Bound<M>, Ordinal>
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        Tagged<Finite.Bound<M>, Ordinal>(_unchecked: underlying)
    }

    @inlinable
    public func projected<let N: Int, let M: Int>() -> Tagged<Finite.Bound<M>, Ordinal>?
    where Tag == Finite.Bound<N>, Underlying == Ordinal {
        guard underlying < Finite.Bound<M>.capacity else { return nil }
        return Tagged<Finite.Bound<M>, Ordinal>(_unchecked: underlying)
    }
}

extension Tagged where Tag: ~Copyable & ~Escapable {

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
