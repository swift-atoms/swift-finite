public import Cardinal
#if Tagged
public import Index
public import Ordinal
public import Tagged

extension Finite::Finite.Enumeration: Swift.Collection {

    public typealias Index = Index::Index<Element>

    @inlinable
    public var startIndex: Index { Index(_unchecked: .zero) }

    @inlinable
    public var endIndex: Index {
        Index(_unchecked: Ordinal::Ordinal(Element.count.rawValue))
    }

    @inlinable
    public subscript(position: Index) -> Element {
        precondition(position.underlying.rawValue < Element.count.rawValue, "Index lies outside the enumeration")
        return Element(_unchecked: (), ordinal: position.underlying)
    }

    @inlinable
    public func index(after i: Index) -> Index {
        precondition(i.underlying.rawValue < Element.count.rawValue, "Cannot advance past the enumeration end")
        return Index(_unchecked: Ordinal::Ordinal(i.underlying.rawValue + 1))
    }
}

#endif

#if !Tagged
extension Finite::Finite.Enumeration: Swift.RandomAccessCollection {
    public typealias Index = Int
    public var startIndex: Int { 0 }
    public var endIndex: Int {
        guard let count = Int(exactly: Element.count.rawValue) else {
            preconditionFailure("Enumeration count is not representable as Int")
        }
        return count
    }
    public subscript(position: Int) -> Element {
        precondition(position >= startIndex && position < endIndex, "Index lies outside the enumeration")
        return element(at: position)!
    }
    public func index(after index: Int) -> Int {
        precondition(index >= startIndex && index < endIndex, "Cannot advance past the enumeration end")
        return index + 1
    }
    public func index(before index: Int) -> Int {
        precondition(index > startIndex && index <= endIndex, "Cannot retreat before the enumeration start")
        return index - 1
    }
    public func distance(from start: Int, to end: Int) -> Int {
        precondition((startIndex...endIndex).contains(start) && (startIndex...endIndex).contains(end))
        return end - start
    }
    public func index(_ index: Int, offsetBy distance: Int) -> Int {
        precondition((startIndex...endIndex).contains(index))
        let result = index.addingReportingOverflow(distance)
        precondition(!result.overflow && (startIndex...endIndex).contains(result.partialValue))
        return result.partialValue
    }
    public func index(_ index: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        precondition((startIndex...endIndex).contains(index) && (startIndex...endIndex).contains(limit))
        let available = limit - index
        if distance >= 0, limit >= index, distance > available { return nil }
        if distance < 0, limit <= index, distance < available { return nil }
        return self.index(index, offsetBy: distance)
    }

}
#endif
