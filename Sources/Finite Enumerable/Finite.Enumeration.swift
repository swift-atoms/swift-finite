import Cardinal
public import Finite_Primitive
import Index
public import Iterator_Primitive
public import Iterator_Protocol
import Ordinal

extension Finite {

    public struct Enumeration<Element: Finite.Enumerable>: Swift.Sequence, Sendable {

        @inlinable
        public init() {}

        @inlinable
        public func makeIterator() -> Iterator {
            Iterator()
        }

        public struct Iterator: Iterator_Primitive.Iterator.`Protocol`, IteratorProtocol, Sendable {
            @usableFromInline
            var index: Ordinal.Ordinal = .zero

            @inlinable
            package init() {}

            @inlinable
            public mutating func next() -> Element? {
                guard index < Element.count else { return nil }
                defer { index += Cardinal.one }
                return Element(_unchecked: (), ordinal: index)
            }
        }
    }
}

extension Finite.Enumeration {

    @inlinable
    public func element(at position: Int) -> Element? {
        guard let ordinal = Ordinal.Ordinal(exactly: position) else { return nil }
        return Element(ordinal)
    }
}

extension Finite.Enumeration: Swift.Collection {

    public typealias Index = Index.Index<Element>

    @inlinable
    public var startIndex: Index { .zero }

    @inlinable
    public var endIndex: Index { Index.Count(Element.count).map(Ordinal.init) }

    @inlinable
    public subscript(position: Index) -> Element {
        Element(_unchecked: (), ordinal: position.position)
    }

    @inlinable
    public func index(after i: Index) -> Index {
        i + Index.Count(Cardinal.one)
    }
}

extension Finite.Enumeration: BidirectionalCollection {

    @inlinable
    public func index(before i: Index) -> Index {

        try! i.predecessor.exact()
    }
}

extension Finite.Enumeration: RandomAccessCollection {

    @inlinable
    public var count: Int { Int(clamping: Element.count) }

    @inlinable
    public func distance(from start: Index, to end: Index) -> Int {
        let endPosition = Int(bitPattern: end)
        let startPosition = Int(bitPattern: start)
        return endPosition - startPosition
    }

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        let position = Int(bitPattern: i)
        let offsetPosition = position + distance
        return Index(_unchecked: Ordinal(UInt(bitPattern: offsetPosition)))
    }

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
        let position = Int(bitPattern: i)
        let result = position + distance
        let limitPosition = Int(bitPattern: limit)
        guard distance >= 0 else {
            return result >= limitPosition
                ? Index(_unchecked: Ordinal(UInt(bitPattern: result))) : nil
        }
        return result <= limitPosition
            ? Index(_unchecked: Ordinal(UInt(bitPattern: result))) : nil
    }
}
