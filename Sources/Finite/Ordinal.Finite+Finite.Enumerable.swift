public import Cardinal
public import Ordinal

extension Ordinal::Ordinal.Finite: Finite::Finite.Enumerable {

    @inlinable
    public static var count: Cardinal::Cardinal { Finite::Finite.Bound<N>.capacity }

    @inlinable
    public var ordinal: Ordinal::Ordinal { underlying }

    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal::Ordinal) {
        self.init(_unchecked: ordinal)
    }
}
