public import Finite_Primitive
import Ordinal_Primitives
import Tagged_Primitives

extension Ordinal {

    public typealias Finite<let N: Int> = Tagged<Finite_Primitive.Finite.Bound<N>, Ordinal>
}
