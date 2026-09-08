public import Cardinal
public import Difference
import Index
import Iterator
public import Ordinal
public import Tagged

extension Finite::Finite.Enumeration: Swift.RandomAccessCollection {

    @inlinable
    public var count: Int {
        guard let count = Int(exactly: Element.count.rawValue) else {
            preconditionFailure("Enumeration count is not representable as Int")
        }
        return count
    }

    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        precondition(
            start.underlying.rawValue <= Element.count.rawValue
                && end.underlying.rawValue <= Element.count.rawValue,
            "Distance requires valid enumeration indices"
        )
        guard let distance = Int(exactly: end.underlying - start.underlying) else {
            preconditionFailure("Enumeration distance is not representable as Int")
        }
        return distance
    }

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        precondition(i.underlying.rawValue <= Element.count.rawValue, "Offset requires a valid enumeration index")
        guard let position = try? i.underlying + Difference(distance),
            position.rawValue <= Element.count.rawValue
        else {
            preconditionFailure("Offset lies outside the enumeration")
        }
        return Index(_unchecked: position)
    }

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
        precondition(
            i.underlying.rawValue <= Element.count.rawValue
                && limit.underlying.rawValue <= Element.count.rawValue,
            "Limited offset requires valid enumeration indices"
        )
        let offset = Difference(distance)
        let available = limit.underlying - i.underlying
        if distance >= 0 {
            if i.underlying <= limit.underlying && offset > available { return nil }
        } else {
            if limit.underlying <= i.underlying && offset < available { return nil }
        }
        return index(i, offsetBy: distance)
    }
}
