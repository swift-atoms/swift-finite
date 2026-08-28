import Cardinal
import Cardinal_Standard_Library_Integration
import Finite_Bounded
import Finite_Enumerable
import Finite_Test_Support
import Index
import Ordinal
import Ordinal_Cardinal
import Ordinal_Comparison
import Ordinal_Equation
import Ordinal_Hash
import Ordinal_Standard_Library_Integration
import Ordinal_Tagged
import Tagged
import Tagged_Standard_Library_Integration
import Testing

@testable import Finite

@Suite
struct `Enumeration - Collection` {
    @Test
    func `startIndex is zero`() {
        let enumeration = Ordinal.Finite<5>.allCases
        #expect(enumeration.startIndex == .zero)
    }

    @Test
    func `endIndex equals count`() {
        let enumeration = Ordinal.Finite<7>.allCases
        #expect(enumeration.endIndex == 7)
    }

    @Test
    func `count equals count`() {
        let enumeration = Ordinal.Finite<7>.allCases
        #expect(enumeration.count == 7)
    }

    @Test(arguments: [0, 1, 2, 3])
    func `subscript returns correct element`(index: Int) throws {
        let enumeration = Ordinal.Finite<5>.allCases
        typealias I = Finite.Enumeration<Ordinal.Finite<5>>.Index
        let position: I = .init(_unchecked: try Ordinal(index))
        let element = enumeration[position]
        #expect(element == Ordinal.Finite(index)!)
    }

    @Test
    func `index after increments by 1`() {
        let enumeration = Ordinal.Finite<10>.allCases
        #expect(enumeration.index(after: enumeration.startIndex) == 1)
        typealias I = Finite.Enumeration<Ordinal.Finite<10>>.Index
        let i5: I = 5
        #expect(enumeration.index(after: i5) == 6)
    }
}

@Suite
struct `Enumeration - BidirectionalCollection` {
    @Test
    func `index before decrements by 1`() {
        let enumeration = Ordinal.Finite<10>.allCases
        typealias I = Finite.Enumeration<Ordinal.Finite<10>>.Index
        let i5: I = 5
        let i1: I = 1
        #expect(enumeration.index(before: i5) == 4)
        #expect(enumeration.index(before: i1) == 0)
    }

    @Test
    func `reverse iteration`() {
        let enumeration = Ordinal.Finite<3>.allCases
        let reversed = Array(enumeration.reversed())
        #expect(reversed.count == 3)
        #expect(reversed[0] == 2)
        #expect(reversed[1] == 1)
        #expect(reversed[2] == 0)
    }
}

@Suite
struct `Enumeration - RandomAccessCollection` {
    @Test
    func `distance from start to end`() {
        let enumeration = Ordinal.Finite<10>.allCases
        let distance = enumeration.distance(from: enumeration.startIndex, to: enumeration.endIndex)
        #expect(distance == 10)
    }

    @Test
    func `distance between indices`() {
        let enumeration = Ordinal.Finite<10>.allCases
        typealias I = Finite.Enumeration<Ordinal.Finite<10>>.Index
        let i0: I = 0
        let i1: I = 1
        let i2: I = 2
        let i5: I = 5
        let i8: I = 8
        #expect(enumeration.distance(from: i0, to: i5) == 5)
        #expect(enumeration.distance(from: i2, to: i8) == 6)
        #expect(enumeration.distance(from: i1, to: i1) == 0)
    }

    @Test
    func `index offsetBy`() {
        let enumeration = Ordinal.Finite<10>.allCases
        typealias I = Finite.Enumeration<Ordinal.Finite<10>>.Index
        let i0: I = 0
        let i3: I = 3
        let i5: I = 5
        #expect(enumeration.index(i0, offsetBy: 5) == 5)
        #expect(enumeration.index(i3, offsetBy: 2) == 5)
        #expect(enumeration.index(i5, offsetBy: -3) == 2)
    }

    @Test
    func `index offsetBy limitedBy succeeds when within limit`() {
        let enumeration = Ordinal.Finite<10>.allCases
        typealias I = Finite.Enumeration<Ordinal.Finite<10>>.Index
        let i0: I = 0
        let i7: I = 7
        let result = enumeration.index(i0, offsetBy: 5, limitedBy: i7)
        #expect(result == 5)
    }

    @Test
    func `index offsetBy limitedBy returns nil when exceeding limit`() {
        let enumeration = Ordinal.Finite<10>.allCases
        typealias I = Finite.Enumeration<Ordinal.Finite<10>>.Index
        let i0: I = 0
        let i5: I = 5
        let result = enumeration.index(i0, offsetBy: 8, limitedBy: i5)
        #expect(result == nil)
    }

    @Test
    func `index offsetBy limitedBy with negative distance`() {
        let enumeration = Ordinal.Finite<10>.allCases
        typealias I = Finite.Enumeration<Ordinal.Finite<10>>.Index
        let i5: I = 5
        let i1: I = 1
        let i2: I = 2
        let result1 = enumeration.index(i5, offsetBy: -3, limitedBy: i1)
        #expect(result1 == 2)

        let result2 = enumeration.index(i5, offsetBy: -6, limitedBy: i2)
        #expect(result2 == nil)
    }
}

@Suite
struct `Enumeration - Iterator` {
    @Test
    func `iterator produces all elements in order`() {
        let enumeration = Ordinal.Finite<4>.allCases
        var iterator = enumeration.makeIterator()

        #expect(iterator.next() == 0)
        #expect(iterator.next() == 1)
        #expect(iterator.next() == 2)
        #expect(iterator.next() == 3)
        #expect(iterator.next() == nil)
    }

    @Test
    func `iterator exhaustion`() {
        let enumeration = Ordinal.Finite<5>.allCases
        var iterator = enumeration.makeIterator()

        var count = 0
        while iterator.next() != nil {
            count += 1
        }
        #expect(count == 5)
        #expect(iterator.next() == nil)
    }

    @Test
    func `for-in loop iteration`() {
        var values: [Ordinal.Finite<5>] = []
        for ordinal in Ordinal.Finite<5>.allCases {
            values.append(ordinal)
        }
        #expect(values.count == 5)
        #expect(values[0] == 0)
        #expect(values[4] == 4)
    }
}

@Suite
struct `Enumeration - Total Element Access` {
    @Test(arguments: [0, 1, 2, 3, 4])
    func `element at returns value for valid index`(index: Int) {
        let enumeration = Ordinal.Finite<5>.allCases
        let element = enumeration.element(at: index)
        #expect(element != nil)
    }

    @Test(arguments: [-1, 5, 10, 100])
    func `element at returns nil for invalid index`(index: Int) {
        let enumeration = Ordinal.Finite<5>.allCases
        let element = enumeration.element(at: index)
        #expect(element == nil)
    }
}

@Suite
struct `Enumeration - Zero-Cost` {
    @Test
    func `Enumeration is zero-size type`() {
        let enum1 = Ordinal.Finite<3>.allCases
        let enum2 = Ordinal.Finite<3>.allCases

        #expect(Array(enum1) == Array(enum2))
    }

    @Test
    func `multiple iterations produce same sequence`() {
        let enumeration = Ordinal.Finite<5>.allCases
        let array1 = Array(enumeration)
        let array2 = Array(enumeration)
        #expect(array1 == array2)
    }
}
