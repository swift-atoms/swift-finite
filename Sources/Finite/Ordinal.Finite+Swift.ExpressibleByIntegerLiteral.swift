public import Ordinal

extension Ordinal::Ordinal.Finite: Swift.ExpressibleByIntegerLiteral {

    @_disfavoredOverload
    @inlinable
    public init(integerLiteral value: UInt) {
        self.init(_unchecked: Ordinal::Ordinal(value))
    }
}
