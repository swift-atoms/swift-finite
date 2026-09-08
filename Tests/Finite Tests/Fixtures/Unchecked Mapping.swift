import Finite

func proof() {
    let value: Ordinal.Finite<3> = 1
    let invalid: Ordinal.Finite<3> = value.map { _ in Ordinal(99) }
    print(invalid)
}
