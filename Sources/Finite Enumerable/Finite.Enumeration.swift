public import Cardinal
public import Finite
public import Index
public import Iterator
public import Iterator_Protocol
public import Ordinal
public import Ordinal_Comparison
public import Tagged

extension Finite::Finite {

    public struct Enumeration<Element: Finite::Finite.Enumerable>: Swift.Sequence, Sendable {

        @inlinable
        public init() {}

        @inlinable
        public func makeIterator() -> Iterator {
            Iterator()
        }

        public struct Iterator: Iterator::Iterator.`Protocol`, IteratorProtocol, Sendable {
            @usableFromInline
            var index: Ordinal::Ordinal = .zero

            @inlinable
            package init() {}

            @inlinable
            public mutating func next() -> Element? {
                guard index.rawValue < Element.count.rawValue else { return nil }
                defer { index = Ordinal::Ordinal(index.rawValue + 1) }
                return Element(_unchecked: (), ordinal: index)
            }
        }
    }
}

extension Finite::Finite.Enumeration {

    @inlinable
    public func element(at position: Int) -> Element? {
        guard position >= 0 else { return nil }
        return Element(Ordinal::Ordinal(UInt(position)))
    }
}

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
        Element(_unchecked: (), ordinal: position.underlying)
    }

    @inlinable
    public func index(after i: Index) -> Index {
        Index(_unchecked: Ordinal::Ordinal(i.underlying.rawValue + 1))
    }
}

extension Finite::Finite.Enumeration: BidirectionalCollection {

    @inlinable
    public func index(before i: Index) -> Index {
        precondition(i.underlying.rawValue > 0)
        return Index(_unchecked: Ordinal::Ordinal(i.underlying.rawValue - 1))
    }
}

extension Finite::Finite.Enumeration: RandomAccessCollection {

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
