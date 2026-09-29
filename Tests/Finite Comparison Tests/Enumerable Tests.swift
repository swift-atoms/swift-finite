#if Order
import Cardinal
import Finite
import Ordinal
import Testing

extension Order.Comparison {
    @Suite("Enumerable Tests")
    struct Test {
        @Suite struct Unit {}
    }
}

extension Order.Comparison.Test.Unit {
    @Test
    func `count is three`() {
        #expect(Order.Comparison.count == Cardinal(UInt(3)))
    }

    @Test
    func `less is ordinal zero`() {
        let value = Order.Comparison.less
        #expect(value.ordinal == Ordinal(UInt(0)))
        #expect(Order.Comparison(_unchecked: (), ordinal: value.ordinal).ordinal == value.ordinal)
    }

    @Test
    func `equal is ordinal one`() {
        let value = Order.Comparison.equal
        #expect(value.ordinal == Ordinal(UInt(1)))
        #expect(Order.Comparison(_unchecked: (), ordinal: value.ordinal).ordinal == value.ordinal)
    }

    @Test
    func `greater is ordinal two`() {
        let value = Order.Comparison.greater
        #expect(value.ordinal == Ordinal(UInt(2)))
        #expect(Order.Comparison(_unchecked: (), ordinal: value.ordinal).ordinal == value.ordinal)
    }
}
#endif
