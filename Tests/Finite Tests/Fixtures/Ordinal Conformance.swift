import Finite

func requireOrdinal<T: Ordinal.`Protocol`>(_ type: T.Type) {}

func proof() {
    requireOrdinal(Ordinal.Finite<3>.self)
}
