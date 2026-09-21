#if Comparison
import Cardinal
import Finite
import Ordinal
import Testing

extension Comparison {
    @Suite("Enumerable Tests")
    struct Test {
        @Suite struct Unit {}
    }
}

extension Comparison.Test.Unit {
    @Test
    func `count is three`() {
        #expect(Comparison.count == Cardinal(UInt(3)))
    }

    @Test
    func `less is ordinal zero`() {
        let value = Comparison.less
        #expect(value.ordinal == Ordinal(UInt(0)))
        #expect(Comparison(_unchecked: (), ordinal: value.ordinal).ordinal == value.ordinal)
    }

    @Test
    func `equal is ordinal one`() {
        let value = Comparison.equal
        #expect(value.ordinal == Ordinal(UInt(1)))
        #expect(Comparison(_unchecked: (), ordinal: value.ordinal).ordinal == value.ordinal)
    }

    @Test
    func `greater is ordinal two`() {
        let value = Comparison.greater
        #expect(value.ordinal == Ordinal(UInt(2)))
        #expect(Comparison(_unchecked: (), ordinal: value.ordinal).ordinal == value.ordinal)
    }
}
#endif
