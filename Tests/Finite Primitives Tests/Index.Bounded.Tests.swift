import Finite_Primitives_Test_Support
import Testing

@testable import Finite_Primitives

@Suite
struct `Index_Bounded - Type Structure` {
    @Test
    func `typealias resolves to double-tagged`() {
        let finite: Ordinal.Finite<8> = 0
        let idx: Index<Int>.Bounded<8> = Tagged(_unchecked: finite)
        let _: Tagged<Int, Tagged<Finite.Bound<8>, Ordinal>> = idx
    }

    @Test
    func `memory layout matches Ordinal`() {
        #expect(MemoryLayout<Index<Int>.Bounded<8>>.size == MemoryLayout<Ordinal>.size)
        #expect(MemoryLayout<Index<Int>.Bounded<8>>.stride == MemoryLayout<Ordinal>.stride)
        #expect(MemoryLayout<Index<Int>.Bounded<8>>.alignment == MemoryLayout<Ordinal>.alignment)
    }

    @Test
    func `memory layout matches unbounded Index`() {
        #expect(MemoryLayout<Index<Int>.Bounded<8>>.size == MemoryLayout<Index<Int>>.size)
        #expect(MemoryLayout<Index<Int>.Bounded<8>>.stride == MemoryLayout<Index<Int>>.stride)
        #expect(MemoryLayout<Index<Int>.Bounded<8>>.alignment == MemoryLayout<Index<Int>>.alignment)
    }
}

@Suite
struct `Index_Bounded - Bridging` {
    @Test(arguments: [0, 1, 2, 3, 7])
    func `narrowing init returns Some for valid indices`(value: Int) {
        let index: Index<Int> = Index(_unchecked: Ordinal(UInt(value)))
        let bounded: Index<Int>.Bounded<8>? = .init(index)
        #expect(bounded != nil)
    }

    @Test(arguments: [8, 9, 100])
    func `narrowing init returns nil for out-of-bounds`(value: Int) {
        let index: Index<Int> = Index(_unchecked: Ordinal(UInt(value)))
        let bounded: Index<Int>.Bounded<8>? = .init(index)
        #expect(bounded == nil)
    }

    @Test(arguments: [0, 1, 2, 3, 7])
    func `widening init round-trips correctly`(value: Int) {
        let index: Index<Int> = Index(_unchecked: Ordinal(UInt(value)))
        let bounded: Index<Int>.Bounded<8> = .init(index)!
        let roundTripped: Index<Int> = .init(bounded)
        #expect(roundTripped == index)
    }

    @Test(arguments: [0, 1, 2, 3, 7])
    func `map underlying produces same result as widening init`(value: Int) {
        let index: Index<Int> = Index(_unchecked: Ordinal(UInt(value)))
        let bounded: Index<Int>.Bounded<8> = .init(index)!
        let viaInit: Index<Int> = .init(bounded)
        let viaMap = bounded.map { $0.underlying }
        #expect(viaInit == viaMap)
    }
}

@Suite
struct `Index_Bounded - Arithmetic` {
    @Test
    func `successor via underlying`() {
        let finite: Ordinal.Finite<8> = 3
        let bounded: Index<Int>.Bounded<8> = Tagged(_unchecked: finite)
        let next = bounded.underlying.successor()
        #expect(next != nil)
        let expected: Ordinal.Finite<8> = 4
        #expect(next == expected)
    }

    @Test
    func `successor at max returns nil`() {
        let finite: Ordinal.Finite<8> = 7
        let bounded: Index<Int>.Bounded<8> = Tagged(_unchecked: finite)
        let next = bounded.underlying.successor()
        #expect(next == nil)
    }

    @Test
    func `predecessor via underlying`() {
        let finite: Ordinal.Finite<8> = 3
        let bounded: Index<Int>.Bounded<8> = Tagged(_unchecked: finite)
        let previous = bounded.underlying.predecessor()
        #expect(previous != nil)
        let expected: Ordinal.Finite<8> = 2
        #expect(previous == expected)
    }

    @Test
    func `offset via underlying`() {
        let finite: Ordinal.Finite<8> = 3
        let bounded: Index<Int>.Bounded<8> = Tagged(_unchecked: finite)
        let offset = bounded.underlying.offset(by: 2)
        let expected: Ordinal.Finite<8> = 5
        #expect(offset == expected)
    }
}

@Suite
struct `Index_Bounded - Edge Cases` {
    @Test
    func `narrowing with zero capacity always returns nil`() {
        let index: Index<Int> = Index(_unchecked: .zero)
        let bounded: Index<Int>.Bounded<0>? = .init(index)
        #expect(bounded == nil)
    }

    @Test
    func `narrowing with capacity 1 accepts only zero`() {
        let zero: Index<Int> = Index(_unchecked: .zero)
        let one: Index<Int> = Index(_unchecked: Ordinal(UInt(1)))
        let zeroBounded: Index<Int>.Bounded<1>? = .init(zero)
        let oneBounded: Index<Int>.Bounded<1>? = .init(one)
        #expect(zeroBounded != nil)
        #expect(oneBounded == nil)
    }
}
