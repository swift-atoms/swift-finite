import Finite

enum CapacityThree: Finite.Capacity {}

extension CapacityThree {
    static var capacity: Cardinal { 3 }
}

func requireEnumerable<T: Finite.Enumerable>(_ type: T.Type) {}
func requireCaseIterable<T: CaseIterable>(_ type: T.Type) {}
