# Finite enumeration

`@Finite` derives a chosen bijection between the values of a stored product or
nonrecursive sum and the ordinal range `0..<count`. It supplies `count`, `ordinal`,
ordinal construction, and `CaseIterable`. `allCases` is an indexed collection;
it does not allocate all inhabitants up front.

```swift
import Finite_Macro

@Finite
struct Questions {
    let first: Bool?
    let second: Bool?
}

// Questions.count.rawValue == 9
// Questions.allCases enumerates every combination exactly once.
```

`Finite.Enumerable` is the underlying capability. It does not imply `Sendable`
or require `CaseIterable`. Boolean and conditional Optional conformances belong
to this package's protocol, without retroactive standard-library conformances.
Declare concurrency capabilities separately when the consumer requires them.

Products use mixed-radix ranks in declaration order; sums use declaration-order
alternative offsets. Optional starts with `nil`, followed by the wrapped values;
Boolean orders `false` before `true`. Reordering the schema changes ordinals.
Ordinals are not stable persistence identifiers across schema revisions.

Construction must preserve every stored coordinate. The macro accepts a
synthesized memberwise initializer or an explicit initializer consisting solely
of direct field assignments, preserving parameter labels. Validating and
normalizing construction requires a manually established finite witness.
Recursive types are unsupported. Cardinal arithmetic traps rather than wraps
when the result cannot be represented by UInt. Generic requirements follow
stored components, not phantom parameters.

`@Interface` composes finite enumeration for generated inputs whose fields are
standard Boolean types or nested Optionals of those types, including empty
inputs. Domain declarations need no input attributes or conformance strings:

```swift
import Interface_Macro

@Interface
public struct Assessment: Assessment.Interface {
    public protocol Interface {
        func assess(first: Bool?, second: Bool?) -> Bool?
    }
}
```

The composition also derives a lazy `values` collection for homogeneous inputs
when its member names are available. Enumeration and coordinate access remain
separate capabilities, owned by `@Finite` and `@Representable` respectively.
`@Operations` itself has no dependency on either derivation.

Automatic finite eligibility is conservative syntax analysis, not compiler type
resolution: arbitrary nominal types and aliases are not automatically recognized
as finite. Explicit `@Finite` derivation continues to support components with
`Finite.Enumerable` witnesses. Swift Testing can consume `Input.allCases` once
that input separately conforms to `Sendable`.

Use the local `macros.xcworkspace`, scheme `Finite Inputs`, to exercise the finite
laws, operation/interface composition, and the BW2 article 1.1 consumer together.

## Optional integrations

Core finite enumeration, macros, and bounded ordinal operations are available without optional dependencies. Enumeration uses Swift `Int` indices by default. Enable `Tagged` to use domain-tagged indices and related adapters; this enables the matching Cardinal and Ordinal integrations. `Algebra` and `Comparison` require `Tagged`. `Iterator` adds the iterator protocol integration and requires `Tagged`; `Polarity` is independent. Optional integrations are opt-in; no traits are enabled by default.
