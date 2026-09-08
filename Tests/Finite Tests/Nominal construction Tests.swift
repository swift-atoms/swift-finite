import Finite
import Testing

private func construct<E: Finite.Enumerable>(
    _ type: E.Type,
    at ordinal: Ordinal
) -> E {
    E(_unchecked: (), ordinal: ordinal)
}

@Suite
struct `Nominal bounded ordinals enforce their construction domain` {
    @Test(arguments: [Int.min, -1, 0, 1, 2, 3, Int.max])
    func `Checked integer construction accepts exactly the declared domain`(position: Int) {
        let value = Ordinal.Finite<3>(position)
        let expected = (0..<3).contains(position) ? UInt(position) : nil
        #expect(value?.underlying.rawValue == expected)
    }

    @Test(arguments: [UInt(0), 1, 2, 3, UInt(Int.max), UInt.max])
    func `Checked ordinal construction rejects positions without signed narrowing`(position: UInt) {
        let value = Ordinal.Finite<3>(Ordinal(position))
        #expect(value?.underlying.rawValue == (position < 3 ? position : nil))
    }

    @Test
    func `Empty and negative domains reject checked construction`() {
        let emptyInteger = Ordinal.Finite<0>(Int(0))
        withKnownIssue("Swift integer generic specialization collision: https://github.com/swiftlang/swift/issues/90739") {
            #expect(emptyInteger == nil)
        } when: {
            !_isDebugAssertConfiguration()
        } matching: { issue in
            guard case .expectationFailed = issue.kind else { return false }
            return issue.description == "Expectation failed: emptyInteger == nil (error)"
                && emptyInteger?.underlying.rawValue == 0
        }
        #expect(Ordinal.Finite<0>(Ordinal.zero) == nil)
        let negativeInteger: Ordinal.Finite<-3>? = .init(Int(0))
        let negativeOrdinal: Ordinal.Finite<-3>? = .init(Ordinal.zero)
        #expect(negativeInteger == nil)
        #expect(negativeOrdinal == nil)
    }

    @Test(arguments: [0, 1, 2])
    func `Every retained constructor preserves valid positions`(position: Int) {
        let expected = Ordinal(UInt(position))
        let checked = Ordinal.Finite<3>(position)!
        let compatibleInteger = Ordinal.Finite<3>(_unchecked: position)
        let compatibleOrdinal = Ordinal.Finite<3>(_unchecked: expected)
        let literalInitializer = Ordinal.Finite<3>(integerLiteral: UInt(position))
        let enumerable = construct(Ordinal.Finite<3>.self, at: expected)
        #expect(checked.underlying == expected)
        #expect(compatibleInteger == checked)
        #expect(compatibleOrdinal == checked)
        #expect(literalInitializer == checked)
        #expect(enumerable == checked)
    }

    @Test
    func `Enumeration contains every constructible ordinal exactly once`() {
        let values = Array(Ordinal.Finite<7>.allCases)
        #expect(values.map { $0.underlying.rawValue } == Array(UInt(0)..<7))
        for position in 0..<7 {
            let constructed = Ordinal.Finite<7>(position)!
            #expect(values.filter { $0 == constructed }.count == 1)
        }
        #expect(Ordinal.Finite<7>(Int(7)) == nil)
    }

    @Test(arguments: [
        "integer", "ordinal", "literal", "enumerable", "negativeInteger",
        "wideOrdinal", "wideLiteral", "boundedIndexLiteral",
    ])
    func `Nonfailable public constructors reject positions outside the domain`(
        constructor: String
    ) async {
        await #expect(processExitsWith: .failure) { [constructor = constructor as String] in
            switch constructor {
            case "integer":
                print(Ordinal.Finite<3>(_unchecked: Int(3)).underlying.rawValue)
            case "ordinal":
                print(Ordinal.Finite<3>(_unchecked: Ordinal(3)).underlying.rawValue)
            case "literal":
                let value: Ordinal.Finite<3> = 3
                print(value.underlying.rawValue)
            case "enumerable":
                print(construct(Ordinal.Finite<3>.self, at: Ordinal(3)).underlying.rawValue)
            case "negativeInteger":
                print(Ordinal.Finite<3>(_unchecked: Int(-1)).underlying.rawValue)
            case "wideOrdinal":
                print(Ordinal.Finite<3>(_unchecked: Ordinal(UInt.max)).underlying.rawValue)
            case "wideLiteral":
                print(Ordinal.Finite<3>(integerLiteral: UInt.max).underlying.rawValue)
            case "boundedIndexLiteral":
                let value: Index<Int>.Bounded<3> = 3
                print(value.underlying.underlying.rawValue)
            default:
                preconditionFailure("Unknown constructor")
            }
        }
    }

    @Test
    func `Zero requires a nonempty bounded domain`() async {
        let valid: Ordinal.Finite<1> = .zero
        #expect(valid.underlying == 0)
        await withKnownIssue("Swift integer generic specialization collision: https://github.com/swiftlang/swift/issues/90739") {
            await #expect(processExitsWith: .failure) {
                print(Ordinal.Finite<0>.zero.underlying.rawValue)
            }
        } when: {
            !_isDebugAssertConfiguration()
        } matching: { issue in
            guard case .expectationFailed = issue.kind else { return false }
            return issue.description.contains("EXIT_SUCCESS")
        }
    }

    @Test(arguments: ["integer", "ordinal", "literal", "enumerable", "zero"])
    func `Nonfailable construction cannot produce an ordinal for a negative domain`(
        constructor: String
    ) async {
        await #expect(processExitsWith: .failure) { [constructor = constructor as String] in
            switch constructor {
            case "integer":
                let value: Ordinal.Finite<-3> = .init(_unchecked: Int(0))
                print(value.underlying.rawValue)
            case "ordinal":
                let value: Ordinal.Finite<-3> = .init(_unchecked: Ordinal.zero)
                print(value.underlying.rawValue)
            case "literal":
                let value: Ordinal.Finite<-3> = 0
                print(value.underlying.rawValue)
            case "enumerable":
                typealias Negative = Ordinal.Finite<-3>
                print(construct(Negative.self, at: .zero).underlying.rawValue)
            case "zero":
                let value: Ordinal.Finite<-3> = .zero
                print(value.underlying.rawValue)
            default:
                preconditionFailure("Unknown constructor")
            }
        }
    }

    @Test
    func `Safe scalar conveniences preserve their domain and ordinal views`() {
        let low: Ordinal.Finite<3> = 0
        let high: Ordinal.Finite<3> = 2
        #expect(Ordinal.Finite<3>.min(low, high) == low)
        #expect(Ordinal.Finite<3>.max(low, high) == high)
        #expect(high.position == high.ordinal)
        #expect(high.description == "2")
        let count: Ordinal.Finite<3>.Count = .init(Ordinal.Finite<3>.capacity())
        let offset: Ordinal.Finite<3>.Offset = .init(Difference(-1))
        let _: Ordinal.Finite<3>.Domain.Type = Finite.Bound<3>.self
        let underlying: Ordinal.Finite<3>.Underlying = high.underlying
        #expect(count.underlying == 3)
        #expect(offset.underlying == -1)
        #expect(underlying == 2)
    }

    @Test
    func `Outer index tags retain bounded values through retagging and checked bridges`() {
        struct Domain: ~Copyable, ~Escapable {}
        let ordinal: Ordinal.Finite<3> = 2
        let index: Index<Int>.Bounded<3> = Tagged(_unchecked: ordinal)
        let retagged: Index<Domain>.Bounded<3> = index.retag(Domain.self)
        let widened: Index<Domain> = Index(retagged)
        let mapped: Index<Domain> = retagged.map { $0.underlying }
        let restored: Index<Domain>.Bounded<3>? = .init(widened)
        #expect(retagged.underlying == ordinal)
        #expect(widened == mapped)
        #expect(restored?.underlying == ordinal)
        let outside: Index<Domain> = .init(Ordinal(3))
        let rejected: Index<Domain>.Bounded<3>? = .init(outside)
        #expect(rejected == nil)
    }
}
