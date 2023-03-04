defmodule ExUtils do
  defmacro __using__ do
    quote do
      import ExUtils.EctoUtils
    end
  end
end
