public import Cardinal
public import Index
public import Iterator
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
        Element(_unchecked: (), ordinal: position.underlying)
    }

    @inlinable
    public func index(after i: Index) -> Index {
        Index(_unchecked: Ordinal::Ordinal(i.underlying.rawValue + 1))
    }
}
