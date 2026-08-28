public import Cardinal
public import Finite_Capacity
public import Finite
public import Ordinal
public import Tagged

extension Tagged::Tagged: @retroactive CaseIterable
where Tag: Finite::Finite.Capacity, Underlying == Ordinal::Ordinal {}

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
