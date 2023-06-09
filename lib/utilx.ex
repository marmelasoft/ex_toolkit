defmodule Utilx do
  defmacro __using__ do
    quote do
      alias Utilx.BenchUtils
      alias Utilx.EctoUtils
      alias Utilx.GitUtils
      alias Utilx.NamingUtils
    end
  end
end
