public import Cardinal
public import Finite

extension Finite::Finite {

    public protocol Capacity: Sendable {

        static var capacity: Cardinal::Cardinal { get }
    }
}

extension Finite::Finite.Bound: Finite::Finite.Capacity {

    @inlinable
    public static var capacity: Cardinal::Cardinal { Cardinal::Cardinal(UInt(N)) }
}
