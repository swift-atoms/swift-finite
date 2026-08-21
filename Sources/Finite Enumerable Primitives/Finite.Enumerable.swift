import Cardinal_Primitives
public import Finite_Primitive
import Ordinal_Primitives

extension Finite {

    public protocol Enumerable: CaseIterable, Sendable {

        static var count: Cardinal { get }

        var ordinal: Ordinal_Primitives.Ordinal { get }

        init(_unchecked: Void, ordinal: Ordinal_Primitives.Ordinal)
    }
}

extension Finite.Enumerable {

    @inlinable
    public static var allCases: Finite.Enumeration<Self> {
        Finite.Enumeration()
    }
}

extension Finite.Enumerable {

    @inlinable
    public init?(_ ordinal: Ordinal) {
        guard ordinal < Self.count else { return nil }
        self.init(_unchecked: (), ordinal: ordinal)
    }
}
