public import Cardinal
public import Index
public import Iterator
public import Ordinal
public import Tagged

extension Finite::Finite.Enumeration: Swift.BidirectionalCollection {

    @inlinable
    public func index(before i: Index) -> Index {
        precondition(i.underlying.rawValue > 0)
        return Index(_unchecked: Ordinal::Ordinal(i.underlying.rawValue - 1))
    }
}
