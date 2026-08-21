import Cardinal_Primitives
public import Finite_Primitive

extension Finite {

    public protocol Capacity: Sendable {

        static var capacity: Cardinal { get }
    }
}

extension Finite.Bound: Finite.Capacity {

    @inlinable
    public static var capacity: Cardinal { Cardinal(UInt(N)) }
}
