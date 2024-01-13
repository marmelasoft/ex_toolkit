defmodule ExToolkit do
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
