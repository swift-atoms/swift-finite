import Finite

func exactEndpoint(_ position: UInt) -> UInt? {
    let value = Ordinal.Finite<9_223_372_036_854_775_807>(Ordinal(position))
    return value?.underlying.rawValue
}

func proof() {
    for position in [UInt(0), UInt(Int.max) - 1, UInt(Int.max), UInt.max] {
        let expected = position < UInt(Int.max) ? position : nil
        precondition(exactEndpoint(position) == expected)
    }
}
