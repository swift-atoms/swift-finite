public import Cardinal
public import Ordinal
public import Tagged

extension Tagged::Tagged: @retroactive Swift.CaseIterable
where Tag: Finite::Finite.Capacity, Underlying == Ordinal::Ordinal {}
