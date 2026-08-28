public import Cardinal
public import Finite
public import Ordinal

extension Finite::Finite {

    public protocol Enumerable: CaseIterable, Sendable {

        static var count: Cardinal::Cardinal { get }

        var ordinal: Ordinal::Ordinal { get }

        init(_unchecked: Void, ordinal: Ordinal::Ordinal)
    }
}

extension Finite::Finite.Enumerable {

    @inlinable
    public static var allCases: Finite::Finite.Enumeration<Self> {
        Finite::Finite.Enumeration()
    }
}

extension Finite::Finite.Enumerable {

    @inlinable
    public init?(_ ordinal: Ordinal::Ordinal) {
        guard ordinal.rawValue < Self.count.rawValue else { return nil }
        self.init(_unchecked: (), ordinal: ordinal)
    }
}
