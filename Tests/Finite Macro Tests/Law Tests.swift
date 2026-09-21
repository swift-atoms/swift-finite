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

@Finite private struct Questions: Equatable {
    let first: Bool?
    let second: Bool?
    init(_ first: Bool?, answer second: Bool?) {
        self.first = first
        self.second = second
    }
}

private final class Unconstrained {}
@Finite private struct Phantom<Marker> { let value: Bool }

@Test func standardLibraryLeavesAndExplicitFieldwiseConstruction() {
    #expect(Array(Bool.allCases) == [false, true])
    #expect(Array(Bool?.allCases) == [nil, false, true])
    #expect(Questions.count.rawValue == 9)
    #expect(Questions.allCases.allSatisfy { Questions($0.ordinal) == $0 })
    #expect(Phantom<Unconstrained>.count.rawValue == 2)
    #expect(Bool??.count.rawValue == 4)
    #expect(Bool??.allCases.allSatisfy { Bool??($0.ordinal)?.ordinal == $0.ordinal })
}

@Finite private enum OptionalChoice: Equatable {
    case absent
    case values(left: Bool?, right: Bool?)
}
@Finite private struct Maybe<Value> { let value: Value? }

@Test func optionalPayloadsComposeInSumsAndGenericProducts() {
    #expect(OptionalChoice.count.rawValue == 10)
    #expect(OptionalChoice.allCases.allSatisfy { OptionalChoice($0.ordinal) == $0 })
    #expect(Maybe<Bool>.count.rawValue == 3)
}

@Finite private struct NativeFields: Finite.Enumerable, CaseIterable {
    let value: Bool
}

@Finite private enum NativeCases: CaseIterable { case first, second }

@Test func nativeConformancesPreserveSynthesizedConstruction() {
    #expect(NativeFields(value: true).ordinal.rawValue == 1)
    #expect(NativeFields.allCases.count == 2)
    #expect(NativeCases.count.rawValue == 2)
}

@Finite private struct WideProduct {
    let field0: Bool?
    let field1: Bool?
    let field2: Bool?
    let field3: Bool?
    let field4: Bool?
    let field5: Bool?
    let field6: Bool?
    let field7: Bool?
    let field8: Bool?
    let field9: Bool?
    let field10: Bool?
    let field11: Bool?
    let field12: Bool?
    let field13: Bool?
    let field14: Bool?
    let field15: Bool?
    let field16: Bool?
    let field17: Bool?
    let field18: Bool?
}

@Test func wideProductsPreserveRankWithoutDeeplyNestedSyntax() {
    #expect(WideProduct.count.rawValue == 1_162_261_467)
    for rank: UInt in [0, 1, 3, 581_130_733, 1_162_261_466] {
        #expect(WideProduct(Ordinal(rank))?.ordinal.rawValue == rank)
    }
}
