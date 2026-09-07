public import Cardinal
public import Ordinal
public import Tagged

extension Tagged::Tagged: Finite::Finite.Enumerable
where Tag: Finite::Finite.Capacity, Underlying == Ordinal::Ordinal {

    @inlinable
    public static var count: Cardinal::Cardinal { Tag.capacity }

    @inlinable
    public var ordinal: Ordinal::Ordinal { underlying }

    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal::Ordinal) {
        self.init(_unchecked: ordinal)
    }
}
