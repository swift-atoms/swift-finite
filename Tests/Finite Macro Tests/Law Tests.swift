import Finite_Macro
import Testing
@Finite private enum Bit: Equatable { case zero; case one }
@Finite private struct Bits: Equatable { let first: Bit; let second: Bit }
@Finite private enum Choice: Equatable { case unit; case single(Bit); case pair(left: Bit, right: Bit) }
@Finite private enum Empty {}
@Finite private struct Unit {}
@Finite private struct Generic<Value: Finite.Enumerable> { let value: Value }
@Test func sumsAndProductsHaveExpectedCardinalityAndBijections() {
    #expect(Bit.count.rawValue == 2)
    #expect(Bits.count.rawValue == 4)
    #expect(Choice.count.rawValue == 7)
    #expect(Empty.count.rawValue == 0)
    #expect(Unit.count.rawValue == 1)
    #expect(Generic<Bit>.count.rawValue == 2)
    for rank in 0..<Choice.count.rawValue {
        let value = Choice(Ordinal(rank))
        #expect(value?.ordinal.rawValue == rank)
    }
    for value in Choice.allCases { #expect(Choice(value.ordinal) == value) }
    for value in Bits.allCases { #expect(Bits(value.ordinal) == value) }
    #expect(Choice(Ordinal(Choice.count.rawValue)) == nil)
    #expect(Empty.allCases.isEmpty)
    #expect(Unit.allCases.count == 1)
    #expect(Finite.productCardinality([UInt.max, UInt.max, 0]) == 0)
}
@Test func declarationOrderIsStableWithinTheChosenSchema() {
    #expect(Choice.unit.ordinal.rawValue == 0)
    #expect(Choice.single(.zero).ordinal.rawValue == 1)
    #expect(Choice.single(.one).ordinal.rawValue == 2)
    #expect(Choice.pair(left: .one, right: .zero).ordinal.rawValue == 5)
}

@Test func cardinalArithmeticRejectsOverflowWithoutWrapping() {
    #expect(Finite.productCardinalityIfRepresentable([UInt.max, 2]) == nil)
    #expect(Finite.sumCardinalityIfRepresentable([UInt.max, 1]) == nil)
    #expect(Finite.productCardinalityIfRepresentable([]) == 1)
    #expect(Finite.sumCardinalityIfRepresentable([]) == 0)
    #expect(Finite.productCardinalityIfRepresentable([UInt.max, UInt.max, 0]) == 0)
}
