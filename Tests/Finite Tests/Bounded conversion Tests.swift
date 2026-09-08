import Finite
import Testing

@Suite
struct `Bounded ordinal conversions preserve the destination domain` {
    @Test(arguments: [0, 1, 2])
    func `Injection preserves every source value in equal and larger domains`(position: Int) {
        let source = Ordinal.Finite<3>(position)!
        let same: Ordinal.Finite<3> = source.injected()
        let larger: Ordinal.Finite<8> = source.injected()
        #expect(same.underlying.rawValue == UInt(position))
        #expect(larger.underlying.rawValue == UInt(position))
        let restored: Ordinal.Finite<3>? = larger.projected()
        #expect(restored == source)
    }

    @Test(arguments: [0, 4])
    func `Injection rejects a smaller destination even when one value would fit`(position: Int) async {
        await #expect(processExitsWith: .failure) { [position = position as Int] in
            let source = Ordinal.Finite<5>(position)!
            let result: Ordinal.Finite<3> = source.injected()
            print(result.underlying.rawValue)
        }
    }

    @Test
    func `Injection requires a source value within its declared domain`() async {
        await #expect(processExitsWith: .failure) {
            let source = Ordinal.Finite<3>(_unchecked: Int(3))
            let result: Ordinal.Finite<8> = source.injected()
            print(result.underlying.rawValue)
        }
    }

    @Test
    func `Projection selects exactly the destination prefix of the source domain`() {
        for position in 0..<8 {
            let source = Ordinal.Finite<8>(position)!
            let result: Ordinal.Finite<3>? = source.projected()
            #expect(result?.underlying.rawValue == (position < 3 ? UInt(position) : nil))
            let empty: Ordinal.Finite<0>? = source.projected()
            #expect(empty == nil)
        }
    }

    @Test
    func `Projection into a negative bound returns no ordinal`() async {
        await #expect(processExitsWith: .success) {
            let source = Ordinal.Finite<3>(Int(1))!
            let result: Ordinal.Finite<-3>? = source.projected()
            precondition(result == nil)
        }
    }
}
