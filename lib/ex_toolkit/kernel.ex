defmodule ExToolkit.Kernel do
  @moduledoc """
  Basic language primitives to ease development flow.
  """

  @doc """
  Defines a module attribute and a function to get it. Inspired by `attr_reader`
  from ruby.

  ## Examples

      iex> defmodule ExampleModule do
      ...>   require ExToolkit.Kernel
      ...>   defattr foo: :bar
      ...> end
      iex> ExampleModule.foo()
      :bar

      iex> defmodule ExampleModule2 do
      ...>   require ExToolkit.Kernel
      ...>   defattr name: "ExToolkit", version: "1.0.0"
      ...> end
      iex> %{name: ExampleModule2.name(), version: ExampleModule2.version()}
      %{name: "ExToolkit", version: "1.0.0"}

      iex> defmodule ExampleModule3 do
      ...>   require ExToolkit.Kernel
      ...>   defattr [version: Version.parse!("1.0.1")]
      ...> end
      iex> ExampleModule3.version()
      %Version{major: 1, minor: 0, patch: 1}
  """
  defmacro defattr(attrs) when is_list(attrs) do
    Enum.map(attrs, fn {key, value} ->
      quote do
        Module.put_attribute(__MODULE__, unquote(key), unquote(value))
        @attr unquote(value)

        @doc """
        Gets @#{unquote(key)}.

        ## Examples
            iex> #{unquote(__MODULE__)}.#{unquote(key)}()
            #{inspect(unquote(value))}
        """
        @spec unquote(key)() :: unquote(type_of(value))()
        def unquote(key)() do
          @attr
        end
      end
    end)
  end

  @doc false
  # credo:disable-for-lines:16 Credo.Check.Refactor.CyclomaticComplexity
  def type_of(a) do
    cond do
      is_float(a) -> :float
      is_integer(a) -> :integer
      is_number(a) -> :number
      is_boolean(a) -> :boolean
      is_atom(a) -> :atom
      is_binary(a) -> :binary
      is_list(a) -> :list
      is_tuple(a) -> :tuple
      is_struct(a) -> :struct
      is_map(a) -> :map
      is_function(a) -> :function
      true -> :term
    end
  end
end
