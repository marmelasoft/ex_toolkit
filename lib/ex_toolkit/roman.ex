defmodule ExToolkit.Roman do
  @valid_romans ["I", "V", "X", "L", "C", "D", "M"]

  def is_valid_roman(string) do
    string
    |> String.upcase()
    |> String.graphemes()
    |> is_valid_roman(@valid_romans)
  end

  defp is_valid_roman([], _), do: true

  defp is_valid_roman([head | tail], valid_romans) do
    if Enum.member?(@valid_romans, head) do
      is_valid_roman(tail, valid_romans)
    else
      false
    end
  end
end
