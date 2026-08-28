import Cardinal
public import Finite

extension Finite {

    public protocol Capacity: Sendable {

        static var capacity: Cardinal { get }
    }
}

extension Finite.Bound: Finite.Capacity {

    @inlinable
    public static var capacity: Cardinal { Cardinal(UInt(N)) }
}
