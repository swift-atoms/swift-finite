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
struct `Enumerable - Protocol` {

    @Test
    func `count returns correct count`() {
        #expect(Ordinal.Finite<5>.count == 5)
        #expect(Ordinal.Finite<10>.count == 10)
    }

    @Test(arguments: [0, 1, 2])
    func `ordinal returns valid index`(index: Int) {
        let ordinal = Ordinal.Finite<5>(index)!
        let ord = ordinal.ordinal
        #expect(ord >= 0)
        #expect(ord < Ordinal.Finite<5>.count)
    }

    @Test(arguments: [0, 1, 2, 3, 4])
    func `init __unchecked creates correct value`(index: Int) {
        let ordinal = Ordinal.Finite<5>(_unchecked: index)
        #expect(ordinal == Ordinal.Finite(index)!)
    }

    @Test(arguments: [0, 1, 2, 3, 4])
    func `ordinal roundtrip`(index: Int) {
        let ordinal = Ordinal.Finite<5>(_unchecked: index)
        let ord = ordinal.ordinal
        let reconstructed = Ordinal.Finite<5>(_unchecked: (), ordinal: ord)
        #expect(reconstructed == ordinal)
    }

    @Test
    func `allCases returns Enumeration`() {
        let allCases = Ordinal.Finite<5>.allCases
        #expect(allCases.count == 5)
    }

    @Test(arguments: [0, 1, 2])
    func `failable init returns value for valid index`(index: Int) {
        let ordinal: Ordinal.Finite<3>? = Ordinal.Finite(index)
        #expect(ordinal != nil)
    }

    @Test(arguments: [-1, 3, 10, 100])
    func `failable init returns nil for invalid index`(index: Int) {
        let invalid: Ordinal.Finite<3>? = Ordinal.Finite(index)
        #expect(invalid == nil)
    }
}

@Suite
struct `Enumerable - Ordinal Tests` {
    @Test
    func `Ordinal conforms to Enumerable`() {
        let ordinal: Ordinal.Finite<5> = 2
        #expect(ordinal.ordinal == 2)
        #expect(Ordinal.Finite<5>.count == 5)
    }

    @Test(arguments: [0, 1, 2, 3, 4])
    func `Ordinal allCases iteration`(expectedIndex: Int) {
        let allCases = Array(Ordinal.Finite<5>.allCases)
        #expect(allCases[expectedIndex] == Ordinal.Finite(expectedIndex)!)
    }

    @Test
    func `Ordinal Enumeration is RandomAccessCollection`() {
        let enumeration = Ordinal.Finite<10>.allCases
        #expect(enumeration.count == 10)
        #expect(enumeration.startIndex == .zero)
        #expect(enumeration.endIndex == 10)
    }
}
