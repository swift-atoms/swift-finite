import Finite

func proof() {
    let value: Ordinal.Finite<3> = 1
    let invalid: Ordinal.Finite<1> = value.retag(Finite.Bound<1>.self)
    print(invalid)
}
