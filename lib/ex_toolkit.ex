defmodule ExToolkit do
  @moduledoc File.read!("README.md") |> String.split("\n\n") |> tl() |> Enum.join("\n\n")

  defmacro __using__ do
    quote do
      alias ExToolkit.Bench, as: BenchUtils
      alias ExToolkit.Ecto
      alias ExToolkit.Encode
      alias ExToolkit.Git
      alias ExToolkit.Naming
    end
  end
end
