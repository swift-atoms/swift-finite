extension Finite {
    /// A zero factor makes a product empty even when another partial product would overflow.
    public static func productCardinalityIfRepresentable(_ factors: [UInt]) -> UInt? {
        if factors.contains(0) { return 0 }
        var accumulated: UInt = 1
        for next in factors {
            let result = accumulated.multipliedReportingOverflow(by: next)
            guard !result.overflow else { return nil }
            accumulated = result.partialValue
        }
        return accumulated
    }
    public static func sumCardinalityIfRepresentable(_ summands: [UInt]) -> UInt? {
        var accumulated: UInt = 0
        for next in summands {
            let result = accumulated.addingReportingOverflow(next)
            guard !result.overflow else { return nil }
            accumulated = result.partialValue
        }
        return accumulated
    }
    public static func productCardinality(_ factors: [UInt]) -> UInt {
        guard let value = productCardinalityIfRepresentable(factors) else { preconditionFailure("Finite product cardinality exceeds UInt") }
        return value
    }
    public static func sumCardinality(_ summands: [UInt]) -> UInt {
        guard let value = sumCardinalityIfRepresentable(summands) else { preconditionFailure("Finite sum cardinality exceeds UInt") }
        return value
    }
}
