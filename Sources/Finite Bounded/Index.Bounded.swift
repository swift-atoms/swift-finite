public import Finite
import Index
import Ordinal
import Tagged

extension Tagged where Underlying == Ordinal, Tag: ~Copyable & ~Escapable {

    public typealias Bounded<let N: Int> = Tagged<Tag, Ordinal.Finite<N>>
}

extension Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public init?<let N: Int>(_ index: Tagged<Tag, Ordinal>)
    where Underlying == Tagged<Finite.Bound<N>, Ordinal> {
        guard let finite = Ordinal.Finite<N>(index.underlying) else { return nil }
        self.init(_unchecked: finite)
    }
}

extension Tagged where Underlying == Ordinal, Tag: ~Copyable & ~Escapable {

    @inlinable
    public init<let N: Int>(_ bounded: Tagged<Tag, Ordinal.Finite<N>>) {
        self = bounded.map { $0.underlying }
    }
}
