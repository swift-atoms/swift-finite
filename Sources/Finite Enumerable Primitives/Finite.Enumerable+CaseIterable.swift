import Cardinal_Primitives
public import Finite_Primitive
import Ordinal_Primitives

extension Finite.Enumerable
where AllCases: RandomAccessCollection, AllCases.Index == Int, Self: Equatable {

    @inlinable
    public static var count: Cardinal {
        Cardinal(UInt(Self.allCases.count))
    }

    @inlinable
    public var ordinal: Ordinal_Primitives.Ordinal {

        let index = Self.allCases.firstIndex(of: self)!
        return Ordinal_Primitives.Ordinal(UInt(index))
    }

    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal_Primitives.Ordinal) {
        self = Self.allCases[Int(ordinal.rawValue)]
    }
}
