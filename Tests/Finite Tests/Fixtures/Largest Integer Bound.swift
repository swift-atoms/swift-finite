import Finite

func exactEndpoint(_ position: UInt) -> UInt? {
    let value = Ordinal.Finite<9223372036854775807>(Ordinal(position))
    return value?.underlying.rawValue
}

func proof() {
    for position in [UInt(0), UInt(Int.max) - 1, UInt(Int.max), UInt.max] {
        let expected = position < UInt(Int.max) ? position : nil
        precondition(exactEndpoint(position) == expected)
    }
}
