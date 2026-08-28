public import Finite
import Ordinal
import Tagged

extension Ordinal {

    public typealias Finite<let N: Int> = Tagged<Finite.Finite.Bound<N>, Ordinal>
}
