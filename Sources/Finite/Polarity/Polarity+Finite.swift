#if Polarity
@_exported public import Polarity
public import Cardinal
public import Ordinal

extension Polarity: Finite.Enumerable {
    /// Positive is ordinal zero; negative is ordinal one. Zero has no polarity.
    @inlinable
    public static var count: Cardinal { Cardinal(UInt(2)) }

    @inlinable
    public var ordinal: Ordinal { Ordinal(self == .positive ? UInt(0) : UInt(1)) }

    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal) {
        precondition(ordinal.rawValue < 2, "Polarity ordinal must be zero or one")
        self = ordinal.rawValue == 0 ? .positive : .negative
    }
}
#endif
