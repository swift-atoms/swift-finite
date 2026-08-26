public import Finite_Primitive
import Ordinal
import Tagged

extension Ordinal {

    public typealias Finite<let N: Int> = Tagged<Finite_Primitive.Finite.Bound<N>, Ordinal>
}
