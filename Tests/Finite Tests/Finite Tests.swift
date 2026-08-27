import Finite
import Testing

@Suite
struct `Finite - Bound` {

    @Test
    func `Bound is constructible`() {
        let bound = Finite.Bound<8>()
        #expect(bound == Finite.Bound<8>())
    }

    @Test
    func `Bound is Hashable`() {
        let bounds: Set<Finite.Bound<8>> = [Finite.Bound(), Finite.Bound()]
        #expect(bounds.count == 1)
    }
}
