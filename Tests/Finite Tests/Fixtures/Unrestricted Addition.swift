import Finite

func proof() {
    let value: Ordinal.Finite<3> = 1
    let invalid = value + 99
    print(invalid)
}
