defmodule ExToolkit.MapTest do
  use ExUnit.Case, async: true

  doctest ExToolkit.Map

  defmodule Inner do
    defstruct [:value]
  end

  defmodule Outer do
    defstruct [:name, :meta]
  end

  test "deep_from_struct converts nested structs inside lists and maps" do
    outer = %Outer{
      name: "test",
      meta: [%Inner{value: %Inner{value: 1}}, %Inner{value: 2}, %{value: 3}]
    }

    assert ExToolkit.Map.deep_from_struct(outer) == %{
             name: "test",
             meta: [%{value: %{value: 1}}, %{value: 2}, %{value: 3}]
           }
  end
end
