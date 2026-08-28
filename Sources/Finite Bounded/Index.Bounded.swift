public import Finite
public import Ordinal
public import Tagged

extension Tagged::Tagged
where Underlying == Ordinal::Ordinal, Tag: ~Copyable & ~Escapable {

    public typealias Bounded<let N: Int> =
        Tagged::Tagged<Tag, Ordinal::Ordinal.Finite<N>>
}

extension Tagged::Tagged where Tag: ~Copyable & ~Escapable {

    @inlinable
    public init?<let N: Int>(_ index: Tagged::Tagged<Tag, Ordinal::Ordinal>)
    where Underlying == Tagged::Tagged<Finite::Finite.Bound<N>, Ordinal::Ordinal> {
        guard let finite = Ordinal::Ordinal.Finite<N>(index.underlying) else { return nil }
        self.init(_unchecked: finite)
    }
}

extension Tagged::Tagged
where Underlying == Ordinal::Ordinal, Tag: ~Copyable & ~Escapable {

    @inlinable
    public init<let N: Int>(
        _ bounded: Tagged::Tagged<Tag, Ordinal::Ordinal.Finite<N>>
    ) {
        self = bounded.map { $0.underlying }
    }
}
