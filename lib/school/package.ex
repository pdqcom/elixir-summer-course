defmodule School.Package do
  @type t :: %__MODULE__{
          type: :letter | :parcel | :fragile,
          weight: pos_integer(),
          destination: :domestic | :eu | :international,
          shipping_class: :standard | :express | :priority,
          declared_value: float(),
          has_customs_form: boolean(),
          has_insurance: boolean(),
          has_fragile_sticker: boolean()
        }

  defstruct type: :letter,
            weight: 100,
            destination: :domestic,
            shipping_class: :standard,
            declared_value: 100,
            has_customs_form: true,
            has_insurance: true,
            has_fragile_sticker: true
end
