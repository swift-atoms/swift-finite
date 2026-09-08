public import Ordinal

extension Ordinal::Ordinal {

    @frozen
    public struct Finite<let N: Int> {

        public let underlying: Ordinal::Ordinal

        @inlinable
        public init?(_ position: Ordinal::Ordinal) {
            guard N > 0, position.rawValue < UInt(N) else { return nil }
            self.underlying = position
        }

        @inlinable
        public init?(_ value: Int) {
            guard value >= 0, value < N else { return nil }
            self.underlying = Ordinal::Ordinal(UInt(value))
        }

        @inlinable
        public init(_unchecked position: Ordinal::Ordinal) {
            precondition(
                N > 0 && position.rawValue < UInt(N),
                "Position lies outside the finite domain"
            )
            self.underlying = position
        }

        @inlinable
        public init(_unchecked value: Int) {
            precondition(value >= 0 && value < N, "Position lies outside the finite domain")
            self.underlying = Ordinal::Ordinal(UInt(value))
        }
    }
}

extension Ordinal::Ordinal.Finite: Swift.Hashable {}

extension Ordinal::Ordinal.Finite: Swift.Sendable {}
