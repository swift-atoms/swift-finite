public import Ordinal

extension Ordinal::Ordinal.Finite: Swift.Comparable {

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.underlying < rhs.underlying
    }

    @inlinable
    public static func min(_ a: Self, _ b: Self) -> Self {
        a.underlying <= b.underlying ? a : b
    }

    @inlinable
    public static func max(_ a: Self, _ b: Self) -> Self {
        a.underlying >= b.underlying ? a : b
    }
}
