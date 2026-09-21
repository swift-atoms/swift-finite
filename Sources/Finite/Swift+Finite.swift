public import Cardinal
public import Ordinal

// These conformances belong to Finite's own protocol. They do not add
// retroactive CaseIterable conformances to standard-library types.
extension Bool: Finite.Enumerable {
    public static var count: Cardinal { Cardinal(UInt(2)) }
    public var ordinal: Ordinal { Ordinal(UInt(self ? 1 : 0)) }
    public init(_unchecked: Void, ordinal: Ordinal) {
        precondition(ordinal.rawValue < 2, "Boolean ordinal is out of range")
        self = ordinal.rawValue == 1
    }
}

extension Optional: Finite.Enumerable where Wrapped: Finite.Enumerable {
    public static var count: Cardinal {
        Cardinal(Finite.sumCardinality([1, Wrapped.count.rawValue]))
    }
    public var ordinal: Ordinal {
        switch self {
        case .none: return Ordinal(UInt(0))
        case .some(let value): return Ordinal(value.ordinal.rawValue + 1)
        }
    }
    public init(_unchecked: Void, ordinal: Ordinal) {
        precondition(ordinal.rawValue < Self.count.rawValue, "Optional ordinal is out of range")
        self = ordinal.rawValue == 0
            ? .none
            : .some(Wrapped(_unchecked: (), ordinal: Ordinal(ordinal.rawValue - 1)))
    }
}
