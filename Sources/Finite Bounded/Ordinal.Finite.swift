public import Finite
public import Ordinal
public import Tagged

extension Ordinal::Ordinal {

    public typealias Finite<let N: Int> =
        Tagged::Tagged<Finite::Finite.Bound<N>, Ordinal::Ordinal>
}
