public import Cardinal
public import Index
public import Iterator
public import Ordinal
public import Tagged

extension Finite::Finite.Enumeration: Swift.RandomAccessCollection {

    @inlinable
    public var count: Int { Int(clamping: Element.count.rawValue) }

    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        let endPosition = Int(bitPattern: end.underlying.rawValue)
        let startPosition = Int(bitPattern: start.underlying.rawValue)
        return endPosition - startPosition
    }

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        let position = Int(bitPattern: i.underlying.rawValue)
        let offsetPosition = position + distance
        return Index(_unchecked: Ordinal::Ordinal(UInt(bitPattern: offsetPosition)))
    }

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
        let position = Int(bitPattern: i.underlying.rawValue)
        let result = position + distance
        let limitPosition = Int(bitPattern: limit.underlying.rawValue)
        guard distance >= 0 else {
            return result >= limitPosition
                ? Index(_unchecked: Ordinal::Ordinal(UInt(bitPattern: result))) : nil
        }
        return result <= limitPosition
            ? Index(_unchecked: Ordinal::Ordinal(UInt(bitPattern: result))) : nil
    }
}
