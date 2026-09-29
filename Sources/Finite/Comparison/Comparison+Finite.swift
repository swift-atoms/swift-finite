#if Order
public import Cardinal
public import Order
public import Index
public import Ordinal
public import Tagged
public import Pair

extension Order.Comparison {

    public typealias Value<Payload> = Pair<Order.Comparison, Payload>
}

extension Order.Comparison: Finite.Enumerable {

    @inlinable
    public static var count: Cardinal { Cardinal(3) }

    @inlinable
    public var ordinal: Ordinal {
        switch self {
        case .less: Ordinal(0)
        case .equal: Ordinal(1)
        case .greater: Ordinal(2)
        }
    }

    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal) {
        switch ordinal.rawValue {
        case 0: self = .less
        case 1: self = .equal
        default: self = .greater
        }
    }
}
#endif
