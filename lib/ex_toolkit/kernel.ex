defmodule ExToolkit.Kernel do
  @moduledoc """
  Basic language primitives to ease development flow.
  """

  @doc """
  Returns the atom `:ok`.

  ## Example

      iex> ok()
      :ok

  """
  @spec ok() :: :ok
  def ok, do: :ok

  @doc """
  Wraps a given value in a tuple tagged with `:ok`.

  ## Examples

      iex> ok(42)
      {:ok, 42}

      iex> ok("hello")
      {:ok, "hello"}

  """
  @spec ok(term()) :: {:ok, term()}
  def ok(value), do: {:ok, value}

  @doc """
  Returns the atom `:error`.

  ## Example

      iex> error()
      :error

  """
  @spec error() :: :error
  def error, do: :error

  @doc """
  Wraps a given value in a tuple tagged with `:error`.

  ## Examples

      iex> error("something went wrong")
      {:error, "something went wrong"}

      iex> error(404)
      {:error, 404}

  """
  @spec error(term()) :: {:error, term()}
  def error(value), do: {:error, value}

  @doc """
  Wraps a given value in a tuple tagged with `:noreply`.

  ## Examples

      iex> noreply("something went wrong")
      {:noreply, "something went wrong"}

      iex> noreply(404)
      {:noreply, 404}

  """
  @spec noreply(term()) :: {:noreply, term()}
  def noreply(value), do: {:noreply, value}

  @doc """
  Validates the given options against the given defaults.

  ## Examples

      iex> validate_opts!([foo: :bar], [foo: :baz])
      %{foo: :bar}

      iex> validate_opts!([], [foo: :baz])
      %{foo: :baz}

      iex> validate_opts!([foo: :bar, bar: :baz], %{foo: :bar})
      ** (ArgumentError) unknown keys [:bar] in [foo: :bar, bar: :baz], the allowed keys are: [:foo]

      iex> validate_opts!(%{foo: :bar, bar: :baz}, %{foo: :bar, bar: :baz})
      %{foo: :bar, bar: :baz}

      iex> validate_opts!(%{foo: :bar}, [foo: :bar])
      %{foo: :bar}

      iex> validate_opts!(%{foo: :bar}, [foo: :baz, bar: :zad])
      %{foo: :bar, bar: :zad}

  """
  @spec validate_opts!(keyword() | map(), keyword() | map()) :: map()
  def validate_opts!(opts, defaults) when is_map(opts) do
    validate_opts!(Keyword.new(opts), defaults)
  end

  def validate_opts!(opts, defaults) when is_map(defaults) do
    validate_opts!(opts, Keyword.new(defaults))
  end

  def validate_opts!(opts, defaults) do
    opts
    |> Keyword.validate!(defaults)
    |> Map.new()
  end

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
            iex> #{__MODULE__}.#{unquote(key)}()
            #{inspect(unquote(value))}
        """
        def unquote(key)() do
          @attr
        end
      end
    end)
  end

  @type type ::
          nil
          | :float
          | :integer
          | :boolean
          | :atom
          | :binary
          | :list
          | :tuple
          | :exception
          | :struct
          | :map
          | :function
          | :pid
          | :term

  @doc """
  Determines the type of the given term.

  ## Examples

      iex> type_of(3.14)
      :float

      iex> type_of(42)
      :integer

      iex> type_of(true)
      :boolean

      iex> type_of(:atom)
      :atom

      iex> type_of("string")
      :binary

      iex> type_of([1, 2, 3])
      :list

      iex> type_of({:ok, 1})
      :tuple

      iex> type_of(%{})
      :map

      iex> type_of(fn -> :ok end)
      :function

      iex> type_of(%URI{})
      :struct

      iex> type_of(%RuntimeError{})
      :exception

      iex> type_of(self())
      :pid

      iex> type_of(nil)
      nil

  """
  @spec type_of(term()) :: type()
  def type_of(a) when is_nil(a), do: nil
  def type_of(a) when is_float(a), do: :float
  def type_of(a) when is_integer(a), do: :integer
  def type_of(a) when is_boolean(a), do: :boolean
  def type_of(a) when is_atom(a), do: :atom
  def type_of(a) when is_binary(a), do: :binary
  def type_of(a) when is_list(a), do: :list
  def type_of(a) when is_tuple(a), do: :tuple
  def type_of(a) when is_exception(a), do: :exception
  def type_of(a) when is_struct(a), do: :struct
  def type_of(a) when is_map(a), do: :map
  def type_of(a) when is_function(a), do: :function
  def type_of(a) when is_pid(a), do: :pid
  def type_of(_), do: :term
end
