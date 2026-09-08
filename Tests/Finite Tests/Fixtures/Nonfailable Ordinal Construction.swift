import Finite

func proof() {
    let invalid: Ordinal.Finite<3> = .init(Ordinal(99))
    print(invalid)
}
