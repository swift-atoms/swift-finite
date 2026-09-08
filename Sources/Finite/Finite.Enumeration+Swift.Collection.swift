public import Cardinal
public import Index
import Iterator
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
