public import Cardinal
public import Ordinal

extension Finite::Finite.Enumerable
where Self: CaseIterable, AllCases: RandomAccessCollection, AllCases.Index == Int, Self: Equatable {

    @inlinable
    public static var count: Cardinal::Cardinal {
        Cardinal::Cardinal(UInt(Self.allCases.count))
    }

    @inlinable
    public var ordinal: Ordinal::Ordinal {

        guard let index = Self.allCases.firstIndex(of: self) else {
            preconditionFailure("Every value is contained in allCases")
        }
        return Ordinal::Ordinal(UInt(index))
    }

    @inlinable
    public init(_unchecked: Void, ordinal: Ordinal::Ordinal) {
        self = Self.allCases[Int(ordinal.rawValue)]
    }
}
