public import Cardinal
public import Difference
public import Ordinal
public import Tagged

extension Ordinal::Ordinal.Finite {

    public typealias Domain = Finite::Finite.Bound<N>

    public typealias Underlying = Ordinal::Ordinal

    public typealias Count = Tagged::Tagged<Domain, Cardinal::Cardinal>

    public typealias Offset = Tagged::Tagged<Domain, Difference::Difference>
}
