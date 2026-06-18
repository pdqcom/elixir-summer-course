defmodule School.LogicTest do
  use ExUnit.Case, async: true

  alias School.Logic
  alias School.Package

  # These tests go through the public Logic.validate/2 function. You pass the
  # package and the list of rules to apply. validate/2 returns {:invalid, msg}
  # for the first rule that fails, or {:valid, "success"} when every applied
  # rule passes.

  describe "validate/2 - a single failing rule" do
    test "fails rule1" do
      package = %Package{type: :letter, weight: 500}
      assert {:invalid, _} = Logic.validate(package, [:rule1])
    end

    test "fails rule2" do
      package = %Package{destination: :international, has_customs_form: false}
      assert {:invalid, _} = Logic.validate(package, [:rule2])
    end

    test "fails rule3" do
      package = %Package{type: :fragile, shipping_class: :standard}
      assert {:invalid, _} = Logic.validate(package, [:rule3])
    end

    test "fails rule4" do
      package = %Package{type: :parcel, weight: 6000, shipping_class: :standard}
      assert {:invalid, _} = Logic.validate(package, [:rule4])
    end

    test "fails rule5" do
      package = %Package{declared_value: 186.5, has_insurance: false}
      assert {:invalid, _} = Logic.validate(package, [:rule5])
    end

    test "fails rule6" do
      package = %Package{type: :fragile, has_fragile_sticker: false}
      assert {:invalid, _} = Logic.validate(package, [:rule6])
    end

    test "fails rule7" do
      package = %Package{destination: :eu, shipping_class: :standard}
      assert {:invalid, _} = Logic.validate(package, [:rule7])
    end

    test "fails rule8" do
      package = %Package{type: :letter, has_insurance: true}
      assert {:invalid, _} = Logic.validate(package, [:rule8])
    end

    test "fails rule9" do
      package = %Package{destination: :domestic, shipping_class: :standard, weight: 2500}
      assert {:invalid, _} = Logic.validate(package, [:rule9])
    end

    test "fails rule10" do
      package = %Package{
        type: :fragile,
        destination: :international,
        shipping_class: :express,
        weight: 1100
      }

      assert {:invalid, _} = Logic.validate(package, [:rule10])
    end
  end

  describe "validate/2 - combining rules" do
    test "a compliant package passes every applied rule" do
      package = %Package{
        type: :parcel,
        weight: 300,
        destination: :domestic,
        shipping_class: :standard,
        declared_value: 50.0,
        has_customs_form: true,
        has_insurance: false,
        has_fragile_sticker: false
      }

      assert {:valid, "success"} = Logic.validate(package, [:rule1, :rule2, :rule3, :rule9])
    end

    test "stops at the first failing rule" do
      package = %Package{type: :fragile, shipping_class: :standard, has_fragile_sticker: false}
      assert {:invalid, _} = Logic.validate(package, [:rule3, :rule6])
    end
  end
end
