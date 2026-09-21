#if Algebra
public import Algebra
public import Cardinal
public import Index
public import Ordinal
public import Tagged

extension Algebra.Group where Element: Finite.Enumerable {

    @inlinable
    public static var cyclic: Self {
        .init(
            identity: Element(_unchecked: (), ordinal: .zero),
            combining: { lhs, rhs in

                let modulus = Element.count.rawValue

                let sum = (lhs.ordinal.rawValue + rhs.ordinal.rawValue) % modulus
                return Element(_unchecked: (), ordinal: Ordinal(sum))
            },
            inverting: { value in

                let modulus = Element.count.rawValue

                let inverse = (modulus - value.ordinal.rawValue) % modulus
                return Element(_unchecked: (), ordinal: Ordinal(inverse))
            }
        )
    }
}
#endif
