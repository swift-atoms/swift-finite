public import Cardinal
public import Finite_Capacity
public import Finite
public import Ordinal
public import Tagged

extension Tagged::Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public init?<let N: Int>(_ position: Ordinal::Ordinal)
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        guard position.rawValue < Finite::Finite.Bound<N>.capacity.rawValue else { return nil }
        self.init(_unchecked: position)
    }

    @inlinable
    public init?<let N: Int>(_ value: Int)
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        guard value >= 0, value < N else { return nil }
        self.init(_unchecked: value)
    }

    @inlinable
    public init<let N: Int>(_unchecked value: Int)
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        self.init(_unchecked: Ordinal::Ordinal(UInt(value)))
    }
}

extension Tagged::Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public static func capacity<let N: Int>() -> Cardinal::Cardinal
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        Finite::Finite.Bound<N>.capacity
    }

    @inlinable
    public static func max<let N: Int>() -> Self?
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        guard N > 0 else { return nil }
        return Self(_unchecked: N - 1)
    }
}

extension Tagged::Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public func successor<let N: Int>() -> Self?
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        let next = underlying.rawValue + 1
        guard next < Finite::Finite.Bound<N>.capacity.rawValue else { return nil }
        return Self(_unchecked: Ordinal::Ordinal(next))
    }

    @inlinable
    public func predecessor<let N: Int>() -> Self?
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        guard underlying.rawValue > 0 else { return nil }
        return Self(_unchecked: Ordinal::Ordinal(underlying.rawValue - 1))
    }
}

extension Tagged::Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public func offset<let N: Int>(by delta: Int) -> Self?
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        let current = Int(bitPattern: underlying.rawValue)
        let result = current + delta
        guard result >= 0, result < N else { return nil }
        return Self(_unchecked: result)
    }

    @inlinable
    public func clamped<let N: Int>(offsetBy delta: Int) -> Self
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        let current = Int(bitPattern: underlying.rawValue)
        let result = current + delta
        if result < 0 { return Self(_unchecked: .zero) }
        if result >= N { return Self(_unchecked: N - 1) }
        return Self(_unchecked: result)
    }
}

extension Tagged::Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public func distance<let N: Int>(to other: Self) -> Int
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        let otherPosition = Int(bitPattern: other.underlying.rawValue)
        let selfPosition = Int(bitPattern: underlying.rawValue)
        return otherPosition - selfPosition
    }
}

extension Tagged::Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public func complement<let N: Int>() -> Self
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        Self(_unchecked: N - 1 - Int(bitPattern: underlying.rawValue))
    }
}

extension Tagged::Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public func injected<let N: Int, let M: Int>()
        -> Tagged::Tagged<Finite::Finite.Bound<M>, Ordinal::Ordinal>
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        Tagged::Tagged<Finite::Finite.Bound<M>, Ordinal::Ordinal>(_unchecked: underlying)
    }

    @inlinable
    public func projected<let N: Int, let M: Int>()
        -> Tagged::Tagged<Finite::Finite.Bound<M>, Ordinal::Ordinal>?
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        guard underlying.rawValue < Finite::Finite.Bound<M>.capacity.rawValue else { return nil }
        return Tagged::Tagged<Finite::Finite.Bound<M>, Ordinal::Ordinal>(_unchecked: underlying)
    }
}

extension Tagged::Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public func decomposed<let N: Int, let Rows: Int, let Columns: Int>()
        -> (
            row: Tagged::Tagged<Finite::Finite.Bound<Rows>, Ordinal::Ordinal>,
            column: Tagged::Tagged<Finite::Finite.Bound<Columns>, Ordinal::Ordinal>
        )?
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        guard Rows * Columns == N else { return nil }
        let position = Int(bitPattern: underlying.rawValue)
        let row = position / Columns
        let column = position % Columns
        return (
            Tagged::Tagged<Finite::Finite.Bound<Rows>, Ordinal::Ordinal>(
                _unchecked: Ordinal::Ordinal(UInt(row))
            ),
            Tagged::Tagged<Finite::Finite.Bound<Columns>, Ordinal::Ordinal>(
                _unchecked: Ordinal::Ordinal(UInt(column))
            )
        )
    }

    @inlinable
    public static func composed<let N: Int, let Rows: Int, let Columns: Int>(
        row: Tagged::Tagged<Finite::Finite.Bound<Rows>, Ordinal::Ordinal>,
        column: Tagged::Tagged<Finite::Finite.Bound<Columns>, Ordinal::Ordinal>
    ) -> Self?
    where Tag == Finite::Finite.Bound<N>, Underlying == Ordinal::Ordinal {
        guard Rows * Columns == N else { return nil }
        let rowPosition = Int(bitPattern: row.underlying.rawValue)
        let columnPosition = Int(bitPattern: column.underlying.rawValue)
        let position = rowPosition * Columns + columnPosition
        return Self(_unchecked: position)
    }
}
