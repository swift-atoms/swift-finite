public import Cardinal
public import Ordinal

extension Finite::Finite {

    public struct Enumeration<Element: Finite::Finite.Enumerable>: Swift::Sequence, Sendable {

        @inlinable
        public init() {}

        public struct Iterator: IteratorProtocol, Sendable {
            @usableFromInline
            var index: Ordinal::Ordinal = .zero

            @inlinable
            package init() {}
        }
    }
}

extension Finite::Finite.Enumeration.Iterator {

    @inlinable
    public mutating func next() -> Element? {
        guard index.rawValue < Element.count.rawValue else { return nil }
        defer { index = Ordinal::Ordinal(index.rawValue + 1) }
        return Element(_unchecked: (), ordinal: index)
    }
}

extension Finite::Finite.Enumeration {

    @inlinable
    public func makeIterator() -> Iterator {
        Iterator()
    }

    @inlinable
    public func element(at position: Int) -> Element? {
        guard position >= 0 else { return nil }
        return Element(Ordinal::Ordinal(UInt(position)))
    }
}

#if Iterator
    public import Iterator
    extension Finite::Finite.Enumeration.Iterator: Iterator::Iterator.`Protocol` {}
#endif
