import Cardinal
public import Finite_Capacity
public import Finite_Primitive
import Ordinal
import Tagged

extension Tagged: @retroactive CaseIterable where Tag: Finite.Capacity, Underlying == Ordinal {}

extension Tagged: Finite.Enumerable where Tag: Finite.Capacity, Underlying == Ordinal {

    @inlinable
    public static var count: Cardinal { Tag.capacity }

    @inlinable
    public var ordinal: Ordinal { underlying }

    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal) {
        self.init(_unchecked: ordinal)
    }
}
