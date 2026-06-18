defmodule School.Logic do
  alias School.Package

  def generate_package do
    type = Enum.random([:letter, :parcel, :fragile])
    weight = calculate_weight(type)
    destination = Enum.random([:domestic, :eu, :international])
    shipping_class = Enum.random([:standard, :express, :priority])
    declared_value = Enum.random(value_range())
    has_fragile_sticker = Enum.random([true, false])
    has_customs_form = Enum.random([true, false])
    has_insurance = Enum.random([true, false])

    %Package{
      type: type,
      weight: weight,
      destination: destination,
      shipping_class: shipping_class,
      declared_value: declared_value,
      has_fragile_sticker: has_fragile_sticker,
      has_customs_form: has_customs_form,
      has_insurance: has_insurance
    }
  end

  def validate_rule1(%{type: :letter, weight: weight}) do
    if weight < 500 do
      {:valid, "rule1"}
    else
      {:invalid, "Letter weights #{weight}g, max 499g"}
    end
  end

  def validate_rule1(_), do: {:valid, "rule1"}

  def validate_rule2(%{destination: :international, has_customs_form: true}),
    do: {:valid, "rule2"}

  def validate_rule2(%{destination: :international, has_customs_form: false}),
    do: {:invalid, "Internation requires customs form"}

  def validate_rule2(_), do: {:valid, "rule2"}

  def validate_rule3(%{type: :fragile, shipping_class: :standard}),
    do: {:invalid, "Fragile can't use standard shipping"}

  def validate_rule3(_), do: {:valid, "rule3"}

  def validate_rule4(%{type: :parcel, weight: weight, shipping_class: :priority}) do
    if weight < 5000 do
      {:valid, "rule4"}
    else
      {:invalid, "Parcel over 5000g (#{weight}g) must use priority shipping"}
    end
  end

  def validate_rule4(_), do: {:valid, "rule4"}

  def validate_rule5(%{declared_value: declared_value, has_insurance: has_insurance})
      when declared_value > 100 do
    if has_insurance do
      {:valid, "rule5"}
    else
      {:invalid, "insurance required for value over 100$ (#{declared_value})"}
    end
  end

  def validate_rule5(_), do: {:valid, "rule5"}

  def validate_rule6(%{type: :fragile, has_fragile_sticker: true}), do: {:valid, "rule6"}

  def validate_rule6(%{type: :fragile, has_fragile_sticker: false}),
    do: {:invalid, "missing fragile sticker for fragile package"}

  def validate_rule6(_), do: {:valid, "rule6"}

  def validate_rule7(%{destination: :eu, shpping_class: shipping_class})
      when shipping_class in [:express, :priority],
      do: {:valid, "rule7"}

  def validate_rule7(%{destination: :international, shipping_class: shipping_class})
      when shipping_class in [:express, :priority],
      do: {:valid, "rule7"}

  def validate_rule7(%{destination: destination, shipping_class: shipping_class})
      when destination in [:eu, :international],
      do: {:invalid, "#{destination} has wrong shipping class: #{shipping_class}"}

  def validate_rule7(_package), do: {:valid, "rule7"}

  def validate_rule8(%{type: :letter, has_insurance: true}),
    do: {:invalid, "letters can't have insurance"}

  def validate_rule8(_package), do: {:valid, "rule8"}

  def validate_rule9(%{shipping_class: :standard, destination: :domestic, weight: weight}) do
    if weight < 2000 do
      {:valid, "rule9"}
    else
      {:invalid, "standard shipping is only available for domestic package under 2000g"}
    end
  end

  def validate_rule10(%{
        type: :fragile,
        destination: :international,
        shipping_class: shipping_class,
        weight: weight
      })
      when weight > 1000 do
    if shipping_class == :priority,
      do: {:valid, "rule10"},
      else: {:invalid, "fragile internationle packages over 1000g must use priority"}
  end

  def validate_rule10(_package) do
    {:valid, "rule10"}
  end

  def calculate_weight(:letter), do: Enum.random(1..600)
  def calculate_weight(_), do: Enum.random(1..10000)

  def value_range do
    10..4000
    |> Range.to_list()
    |> build_value_range([])
    |> Enum.reverse()
  end

  def build_value_range([], acc), do: acc

  def build_value_range([hd | tl], acc) do
    to_float = hd / 10
    new_acc = [to_float | acc]

    build_value_range(tl, new_acc)
  end
end
