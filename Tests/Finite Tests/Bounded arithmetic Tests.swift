import Finite
import Testing

@Suite
struct `Bounded ordinals preserve their domains through arithmetic` {
    @Test(arguments: ["offset", "clamp", "decompose", "compose"])
    func `Unrepresentable intermediate arithmetic returns the declared result`(operation: String) async {
        await #expect(processExitsWith: .success) { [operation = operation as String] in
            let value = Ordinal.Finite<2>(Int(1))!
            switch operation {
            case "offset":
                precondition(value.offset(by: Int.max) == nil)
            case "clamp":
                precondition(value.clamped(offsetBy: Int.max) == value)
            case "decompose":
                let result: (Ordinal.Finite<4294967296>, Ordinal.Finite<4294967296>)? = value.decomposed()
                precondition(result == nil)
            case "compose":
                let component = Ordinal.Finite<4294967296>(Int(1))!
                let result: Ordinal.Finite<2>? = .composed(row: component, column: component)
                precondition(result == nil)
            default:
                preconditionFailure("Unknown operation")
            }
        }
    }

    @Test
    func `Offsets and clamps agree with wider arithmetic at both integer extremes`() {
        let offsets = [Int.min, Int.min + 1, -100, -17, -1, 0, 1, 17, 100, Int.max - 1, Int.max]
        for position in 0..<17 {
            let value = Ordinal.Finite<17>(position)!
            for offset in offsets {
                let mathematical = Int128(position) + Int128(offset)
                let expected = (0..<17).contains(mathematical) ? UInt(mathematical) : nil
                #expect(value.offset(by: offset)?.underlying.rawValue == expected)
                let clamped = max(0, min(mathematical, 16))
                #expect(value.clamped(offsetBy: offset).underlying.rawValue == UInt(clamped))
            }
        }
    }

    @Test
    func `A singleton retains its sole ordinal under every clamped offset`() {
        let value = Ordinal.Finite<1>(Int(0))!
        for offset in [Int.min, -1, 0, 1, Int.max] {
            #expect(value.clamped(offsetBy: offset) == value)
            #expect((value.offset(by: offset) != nil) == (offset == 0))
        }
    }

    @Test
    func `Wide bounded positions retain exact offsets and endpoint clamps`() {
        let position = 4_294_967_295
        let value = Ordinal.Finite<4294967296>(position)!
        #expect(value.offset(by: -position)?.underlying.rawValue == 0)
        #expect(value.offset(by: 0) == value)
        #expect(value.offset(by: 1) == nil)
        #expect(value.offset(by: Int.max) == nil)
        #expect(value.offset(by: Int.min) == nil)
        #expect(value.clamped(offsetBy: Int.max) == value)
        #expect(value.clamped(offsetBy: Int.min).underlying.rawValue == 0)
    }

    @Test
    func `Row major products agree with independent coordinate arithmetic`() {
        for row in 0..<3 {
            for column in 0..<7 {
                let expected = row * 7 + column
                let value: Ordinal.Finite<21>? = .composed(
                    row: Ordinal.Finite<3>(row)!,
                    column: Ordinal.Finite<7>(column)!
                )
                #expect(value?.underlying.rawValue == UInt(expected))
                let coordinates: (Ordinal.Finite<3>, Ordinal.Finite<7>)? =
                    Ordinal.Finite<21>(expected)!.decomposed()
                #expect(coordinates?.0.underlying.rawValue == UInt(row))
                #expect(coordinates?.1.underlying.rawValue == UInt(column))
            }
        }
    }

    @Test
    func `Wide representable products preserve the final row and column`() {
        let row = Ordinal.Finite<65536>(Int(65_535))!
        let column = Ordinal.Finite<65536>(Int(65_535))!
        let value: Ordinal.Finite<4294967296>? = .composed(row: row, column: column)
        #expect(value?.underlying.rawValue == 4_294_967_295)
        let coordinates: (Ordinal.Finite<65536>, Ordinal.Finite<65536>)? = value?.decomposed()
        #expect(coordinates?.0 == row)
        #expect(coordinates?.1 == column)
    }

    @Test
    func `Empty and negative dimensions cannot decompose a nonempty domain`() {
        let value = Ordinal.Finite<4>(Int(1))!
        let emptyRows: (Ordinal.Finite<0>, Ordinal.Finite<4>)? = value.decomposed()
        let emptyColumns: (Ordinal.Finite<4>, Ordinal.Finite<0>)? = value.decomposed()
        let negative: (Ordinal.Finite<-2>, Ordinal.Finite<-2>)? = value.decomposed()
        #expect(emptyRows == nil)
        #expect(emptyColumns == nil)
        #expect(negative == nil)
    }

    @Test
    func `Constructing an ordinal for an empty domain is rejected`() async {
        await withKnownIssue("Swift integer generic specialization collision: https://github.com/swiftlang/swift/issues/90739") {
            await #expect(processExitsWith: .failure) {
                print(Ordinal.Finite<0>(_unchecked: Int(0)).underlying.rawValue)
            }
        } when: {
            !_isDebugAssertConfiguration()
        } matching: { issue in
            guard case .expectationFailed = issue.kind else { return false }
            return issue.description.contains("EXIT_SUCCESS")
        }
    }

    @Test
    func `Distinct finite bounds retain distinct runtime type identities`() {
        withKnownIssue("Swift integer generic metadata collision: https://github.com/swiftlang/swift/issues/90739") {
            #expect(ObjectIdentifier(Finite.Bound<0>.self) != ObjectIdentifier(Finite.Bound<4294967296>.self))
        } matching: { issue in
            if case .expectationFailed = issue.kind { return true }
            return false
        }
    }

    @Test
    func `The compatibility initializer rejects the upper bound of its domain`() async {
        await #expect(processExitsWith: .failure) {
            print(Ordinal.Finite<2>(_unchecked: Int(2)).underlying.rawValue)
        }
    }
}
