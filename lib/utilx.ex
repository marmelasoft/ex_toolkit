defmodule Utilx do
  defmacro __using__ do
    quote do
      import Utilx.EctoUtils
    end
  end
end
