import Finite

func proof() {
    let arbitrary: Tagged<CapacityThree, Ordinal> = .init(Ordinal(99))
    let checked = Ordinal.Finite<3>(Ordinal(2))!
    let values = Array(Ordinal.Finite<3>.allCases)
    requireEnumerable(Ordinal.Finite<3>.self)
    requireCaseIterable(Ordinal.Finite<3>.self)
    let index: Index<Int>.Bounded<3> = .init(checked)
    let retagged: Index<String>.Bounded<3> = index.retag(String.self)
    let unbounded: Index<String> = .init(retagged)
    let reconstructed: Index<String>.Bounded<3>? = .init(unbounded)
    precondition(arbitrary.underlying.rawValue == 99)
    precondition(values.map { $0.underlying.rawValue } == [0, 1, 2])
    precondition(reconstructed?.underlying == checked)
}
