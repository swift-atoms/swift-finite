public import Cardinal
public import Index
public import Iterator
public import Ordinal
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
