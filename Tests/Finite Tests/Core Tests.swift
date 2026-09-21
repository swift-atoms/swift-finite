import Finite
import Ordinal
import Testing

@Suite struct `Core finite enumeration` {
    @Test func `enumeration preserves order and random access without tagging`() {
        let values = Ordinal.Finite<3>.allCases
        #expect(values.count == 3)
        #expect(values.map { $0.underlying.rawValue } == [0, 1, 2])
        #expect(values.reversed().map { $0.underlying.rawValue } == [2, 1, 0])
        #expect(values.element(at: -1) == nil)
        #expect(values.element(at: 3) == nil)
        #if !Tagged
        #expect(values[1].underlying.rawValue == 1)
        #endif
    }

    #if !Tagged
    @Test func `limited offsets agree with arrays across both directions`() {
        let values = Ordinal.Finite<10>.allCases
        let reference = Array(0..<10)
        for start in 0...10 {
            for limit in 0...10 {
                for distance in -12...12 {
                    let result = start + distance
                    let crossesLimit = distance > 0 && limit >= start && result > limit
                        || distance < 0 && limit <= start && result < limit
                    guard (0...10).contains(result) || crossesLimit else { continue }
                    #expect(values.index(start, offsetBy: distance, limitedBy: limit)
                        == reference.index(start, offsetBy: distance, limitedBy: limit))
                }
            }
        }
        #expect(values.index(0, offsetBy: Int.max, limitedBy: 10) == nil)
        #expect(values.index(10, offsetBy: Int.min, limitedBy: 0) == nil)
    }
    #endif
}
