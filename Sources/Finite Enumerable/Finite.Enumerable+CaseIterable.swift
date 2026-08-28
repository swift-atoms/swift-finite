public import Cardinal
public import Finite
public import Ordinal

extension Finite::Finite.Enumerable
where AllCases: RandomAccessCollection, AllCases.Index == Int, Self: Equatable {

    @inlinable
    public static var count: Cardinal::Cardinal {
        Cardinal::Cardinal(UInt(Self.allCases.count))
    }

    @inlinable
    public var ordinal: Ordinal::Ordinal {

        let index = Self.allCases.firstIndex(of: self)!
        return Ordinal::Ordinal(UInt(index))
    }

    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal::Ordinal) {
        self = Self.allCases[Int(ordinal.rawValue)]
    }
}
