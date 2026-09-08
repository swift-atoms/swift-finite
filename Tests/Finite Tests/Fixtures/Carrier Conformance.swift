import Carrier
import Finite

func requireCarrier<T: Carrier.`Protocol`>(_ type: T.Type) {}

func proof() {
    requireCarrier(Ordinal.Finite<3>.self)
}
