import Finite
import Testing

private struct WideElement: Finite.Enumerable {
    static var count: Cardinal { Cardinal(UInt.max) }
    let ordinal: Ordinal

    init(_unchecked: Void, ordinal: Ordinal) {
        self.ordinal = ordinal
    }
}

@Suite
struct `Finite enumeration obeys collection index laws` {
    @Test
    func `An empty enumeration contains no values and retains its end index`() {
        let enumeration = Ordinal.Finite<0>.allCases
        #expect(enumeration.count == 0)
        #expect(enumeration.isEmpty)
        #expect(enumeration.startIndex == enumeration.endIndex)
        #expect(enumeration.element(at: 0) == nil)
        #expect(enumeration.index(enumeration.endIndex, offsetBy: 0) == enumeration.endIndex)
        #expect(enumeration.index(enumeration.endIndex, offsetBy: 1, limitedBy: enumeration.endIndex) == nil)
        #expect(enumeration.index(enumeration.endIndex, offsetBy: -1, limitedBy: enumeration.endIndex) == nil)
        var iterator = enumeration.makeIterator()
        #expect(iterator.next() == nil)
        #expect(iterator.next() == nil)
    }

    @Test
    func `Limited offsets agree with Swift when the limit lies in either direction`() {
        let reference = Array(0..<10)
        let enumeration = Ordinal.Finite<10>.allCases
        typealias Position = Finite.Enumeration<Ordinal.Finite<10>>.Index
        var mismatches: [String] = []
        for start in 0...10 {
            for limit in 0...10 {
                for distance in -12...12 {
                    let result = start + distance
                    let crossesLimit = distance > 0 && limit >= start && result > limit
                        || distance < 0 && limit <= start && result < limit
                    guard (0...10).contains(result) || crossesLimit else { continue }
                    let expected = reference.index(start, offsetBy: distance, limitedBy: limit)
                    let actual = enumeration.index(
                        Position(_unchecked: Ordinal(UInt(start))),
                        offsetBy: distance,
                        limitedBy: Position(_unchecked: Ordinal(UInt(limit)))
                    )
                    if actual.map({ Int($0.underlying.rawValue) }) != expected {
                        mismatches.append("\(start), \(distance), \(limit)")
                    }
                }
            }
        }
        #expect(mismatches.isEmpty)
    }

    @Test
    func `Distances and offsets are inverses for all small collection indices`() {
        let enumeration = Ordinal.Finite<10>.allCases
        typealias Position = Finite.Enumeration<Ordinal.Finite<10>>.Index
        for start in 0...10 {
            for end in 0...10 {
                let first = Position(_unchecked: Ordinal(UInt(start)))
                let last = Position(_unchecked: Ordinal(UInt(end)))
                let distance = enumeration.distance(from: first, to: last)
                #expect(distance == end - start)
                #expect(enumeration.index(first, offsetBy: distance) == last)
            }
        }
        let middle = enumeration[
            Position(_unchecked: Ordinal(2))..<Position(_unchecked: Ordinal(6))
        ]
        #expect(middle.map(\.underlying.rawValue) == [2, 3, 4, 5])
        #expect(middle.reversed().map(\.underlying.rawValue) == [5, 4, 3, 2])
    }

    @Test(arguments: ["count", "positive-distance", "subscript", "after", "before", "offset"])
    func `Invalid collection operations fail without manufacturing values`(operation: String) async {
        await #expect(processExitsWith: .failure) { [operation = operation as String] in
            let wide = WideElement.allCases
            let small = Ordinal.Finite<3>.allCases
            switch operation {
            case "count":
                _ = wide.count
            case "positive-distance":
                let high = Finite.Enumeration<WideElement>.Index(
                    _unchecked: Ordinal(UInt(Int.max) + 1)
                )
                _ = wide.distance(from: wide.startIndex, to: high)
            case "subscript":
                _ = small[small.endIndex]
            case "after":
                _ = small.index(after: small.endIndex)
            case "before":
                let outside = Finite.Enumeration<Ordinal.Finite<3>>.Index(_unchecked: Ordinal(4))
                _ = small.index(before: outside)
            case "offset":
                _ = small.index(small.endIndex, offsetBy: 1)
            default:
                preconditionFailure("Unknown operation")
            }
        }
    }

    @Test
    func `Large valid indices preserve signed distance and offset direction`() async {
        await #expect(processExitsWith: .success) {
            let enumeration = WideElement.allCases
            typealias Position = Finite.Enumeration<WideElement>.Index
            let low = Position(_unchecked: Ordinal(UInt(Int.max)))
            let high = Position(_unchecked: Ordinal(UInt(Int.max) + 1))
            precondition(enumeration.index(low, offsetBy: 1) == high)
            precondition(enumeration.index(high, offsetBy: -1) == low)
            precondition(enumeration.distance(from: high, to: enumeration.startIndex) == Int.min)
            let shifted = enumeration.index(enumeration.endIndex, offsetBy: Int.min)
            precondition(shifted == low)
            precondition(enumeration.index(high, offsetBy: Int.min, limitedBy: low) == nil)
        }
    }

    @Test
    func `Wide cardinality keeps lazy access to both ends without narrowing the collection`() {
        let enumeration = WideElement.allCases
        var iterator = enumeration.makeIterator()
        #expect(iterator.next()?.ordinal == Ordinal.zero)
        #expect(iterator.next()?.ordinal == Ordinal(1))
        let last = enumeration.index(before: enumeration.endIndex)
        #expect(enumeration[last].ordinal == Ordinal(UInt.max - 1))
        #expect(enumeration.distance(from: last, to: enumeration.endIndex) == 1)
        #expect(enumeration.distance(from: enumeration.endIndex, to: last) == -1)
    }
}
