defmodule ExToolkit.Ecto.ObjectID do
  @moduledoc """
  A Ecto type that facilitates the generation of prefixed base62 encoded UUIDv7
  for use as primary and foreign keys in Ecto schemas.

  ## Examples

      @primary_key {:id, ExToolkit.Ecto.ObjectID, prefix: "user", autogenerate: true}
      @foreign_key_type ExToolkit.Ecto.ObjectID

  ## Resources

    - https://dev.to/stripe/designing-apis-for-humans-object-ids-3o5a
    - https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto
  """
  use Ecto.ParameterizedType

  alias ExToolkit.Encode.Base62UUID

  @uuid_version 7

  @type opts :: [schema: atom(), field: atom(), prefix: String.t()]

  @impl true
  def init(opts) do
    schema = Keyword.fetch!(opts, :schema)
    field = Keyword.fetch!(opts, :field)

    uniq =
      Uniq.UUID.init(
        schema: schema,
        field: field,
        version: @uuid_version,
        default: :raw,
        dump: :raw
      )

    case opts[:primary_key] do
      true ->
        prefix = Keyword.get(opts, :prefix) || raise "`:prefix` option is required"

        %{
          primary_key: true,
          schema: schema,
          prefix: prefix,
          uniq: uniq
        }

      _any ->
        %{
          schema: schema,
          field: field,
          uniq: uniq
        }
    end
  end

  @impl true
  def type(_params), do: :uuid

  @impl true
  def cast(nil, _params), do: {:ok, nil}

  def cast(data, params) do
    with {:ok, prefix, _uuid} <- slug_to_uuid(data, params),
         {prefix, prefix} <- {prefix, prefix(params)} do
      {:ok, data}
    else
      _ -> :error
    end
  end

  defp slug_to_uuid(string, _params) do
    with [prefix, slug] <- String.split(string, "_"),
         {:ok, uuid} <- Base62UUID.decode(slug) do
      {:ok, prefix, uuid}
    else
      _ -> :error
    end
  end

  defp prefix(%{primary_key: true, prefix: prefix}), do: prefix

  # If we deal with a belongs_to association we need to fetch the prefix from
  # the associations schema module
  defp prefix(%{schema: schema, field: field}) do
    %{related: schema, related_key: field} = schema.__schema__(:association, field)
    {:parameterized, __MODULE__, %{prefix: prefix}} = schema.__schema__(:type, field)

    prefix
  end

  @impl true
  def load(data, loader, params) do
    case Uniq.UUID.load(data, loader, params.uniq) do
      {:ok, nil} -> {:ok, nil}
      {:ok, uuid} -> {:ok, uuid_to_slug(uuid, params)}
      :error -> :error
    end
  end

  defp uuid_to_slug(uuid, params), do: "#{prefix(params)}_#{Base62UUID.encode(uuid)}"

  @impl true
  def dump(nil, _, _), do: {:ok, nil}

  def dump(slug, dumper, params) do
    case slug_to_uuid(slug, params) do
      {:ok, _prefix, uuid} -> Uniq.UUID.dump(uuid, dumper, params.uniq)
      :error -> :error
    end
  end

  @impl true
  def autogenerate(params) do
    uuid_to_slug(Uniq.UUID.autogenerate(params.uniq), params)
  end

  @impl true
  def embed_as(format, params), do: Uniq.UUID.embed_as(format, params.uniq)

  @impl true
  def equal?(a, b, params), do: Uniq.UUID.equal?(a, b, params.uniq)
end
