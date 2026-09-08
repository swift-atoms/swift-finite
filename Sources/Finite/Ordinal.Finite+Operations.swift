public import Cardinal
public import Difference
public import Ordinal

extension Ordinal::Ordinal.Finite {

    @inlinable
    public static func capacity() -> Cardinal::Cardinal {
        Finite::Finite.Bound<N>.capacity
    }

    @inlinable
    public static func max() -> Self? {
        guard N > 0 else { return nil }
        return Self(_unchecked: N - 1)
    }
}

extension Ordinal::Ordinal.Finite {

    @inlinable
    public func successor() -> Self? {
        let next = underlying.rawValue + 1
        guard next < Finite::Finite.Bound<N>.capacity.rawValue else { return nil }
        return Self(_unchecked: Ordinal::Ordinal(next))
    }

    @inlinable
    public func predecessor() -> Self? {
        guard underlying.rawValue > 0 else { return nil }
        return Self(_unchecked: Ordinal::Ordinal(underlying.rawValue - 1))
    }
}

extension Ordinal::Ordinal.Finite {

    @inlinable
    public func offset(by delta: Int) -> Self? {
        guard N > 0,
            let result = try? underlying + Difference::Difference(delta),
            result.rawValue < UInt(N)
        else { return nil }
        return Self(_unchecked: result)
    }

    @inlinable
    public func clamped(offsetBy delta: Int) -> Self {
        precondition(N > 0 && underlying.rawValue < UInt(N), "Clamping requires a valid bounded ordinal")
        if let result = offset(by: delta) { return result }
        return delta < 0 ? Self(_unchecked: .zero) : Self(_unchecked: N - 1)
    }
}

extension Ordinal::Ordinal.Finite {

    @inlinable
    public func distance(to other: Self) -> Int {
        let otherPosition = Int(bitPattern: other.underlying.rawValue)
        let selfPosition = Int(bitPattern: underlying.rawValue)
        return otherPosition - selfPosition
    }
}

extension Ordinal::Ordinal.Finite {

    @inlinable
    public func complement() -> Self {
        Self(_unchecked: N - 1 - Int(bitPattern: underlying.rawValue))
    }
}

extension Ordinal::Ordinal.Finite {

    @inlinable
    public func injected<let M: Int>()
        -> Ordinal::Ordinal.Finite<M> {
        precondition(
            N > 0 && M >= N && underlying.rawValue < UInt(N),
            "Injection requires a valid source ordinal and an equal or larger destination domain"
        )
        return Ordinal::Ordinal.Finite<M>(_unchecked: underlying)
    }

    @inlinable
    public func projected<let M: Int>()
        -> Ordinal::Ordinal.Finite<M>? {
        guard M > 0, underlying.rawValue < UInt(M) else { return nil }
        return Ordinal::Ordinal.Finite<M>(_unchecked: underlying)
    }
}

extension Ordinal::Ordinal.Finite {

    @inlinable
    public func decomposed<let Rows: Int, let Columns: Int>()
        -> (
            row: Ordinal::Ordinal.Finite<Rows>,
            column: Ordinal::Ordinal.Finite<Columns>
        )? {
        guard Rows > 0, Columns > 0 else { return nil }
        let capacity = Rows.multipliedReportingOverflow(by: Columns)
        guard !capacity.overflow, capacity.partialValue == N else { return nil }
        let position = Int(underlying.rawValue)
        let row = position / Columns
        let column = position % Columns
        return (
            Ordinal::Ordinal.Finite<Rows>(
                _unchecked: Ordinal::Ordinal(UInt(row))
            ),
            Ordinal::Ordinal.Finite<Columns>(
                _unchecked: Ordinal::Ordinal(UInt(column))
            )
        )
    }

    @inlinable
    public static func composed<let Rows: Int, let Columns: Int>(
        row: Ordinal::Ordinal.Finite<Rows>,
        column: Ordinal::Ordinal.Finite<Columns>
    ) -> Self? {
        guard Rows > 0, Columns > 0 else { return nil }
        let capacity = Rows.multipliedReportingOverflow(by: Columns)
        guard !capacity.overflow, capacity.partialValue == N else { return nil }
        let rowPosition = Int(row.underlying.rawValue)
        let columnPosition = Int(column.underlying.rawValue)
        let position = rowPosition * Columns + columnPosition
        return Self(_unchecked: position)
    }
}

extension Ordinal::Ordinal.Finite {

    @inlinable
    public static var zero: Self { Self(_unchecked: Ordinal::Ordinal.zero) }

    @inlinable
    public var position: Ordinal::Ordinal { underlying }
}
