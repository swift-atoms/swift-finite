public import Ordinal

extension Ordinal::Ordinal.Finite: Swift.CustomStringConvertible {

    public var description: String { underlying.description }
}
