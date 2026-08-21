public enum Finite: Sendable {}

extension Finite {

    public struct Bound<let N: Int>: Hashable, Sendable {

        @inlinable
        public init() {}
    }
}
