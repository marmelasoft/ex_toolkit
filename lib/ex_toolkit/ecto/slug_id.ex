defmodule ExToolkit.Ecto.SlugID do
  @moduledoc """
  A Ecto type that facilitates the generation of prefixed base62 encoded UUIDv7
  for use as primary and foreign keys in Ecto schemas.

  ## Examples

      @primary_key {:id, ExToolkit.Ecto.SlugID, autogenerate: true}
      @foreign_key_type ExToolkit.Ecto.SlugID
  """
  use Ecto.ParameterizedType

  alias ExToolkit.Encode.Base62UUID

  @impl true
  def init(opts), do: opts

  @impl true
  def type(_params), do: :uuid

  @impl true
  def cast(nil, _params), do: {:ok, nil}

  def cast(data, _params) do
    with {:ok, _uuid} <- slug_to_uuid(data) do
      {:ok, data}
    else
      _ -> :error
    end
  end

  defp slug_to_uuid(slug) do
    with {:ok, uuid} <- Base62UUID.decode(slug) do
      {:ok, uuid}
    else
      _ -> :error
    end
  end

  defp uuid_to_slug(uuid), do: Base62UUID.encode(uuid)

  @impl true
  def load(nil, _loader, _params), do: {:ok, nil}
  def load(data, _loader, _params) do
    case UUIDv7.load(data) do
      {:ok, uuid} -> {:ok, uuid_to_slug(uuid)}
      :error -> :error
    end
  end

  @impl true
  def dump(nil, _, _), do: {:ok, nil}

  def dump(slug, _dumper, _params) do
    case slug_to_uuid(slug) do
      {:ok, uuid} -> UUIDv7.dump(uuid)
      :error -> :error
    end
  end

  @impl true
  def autogenerate(_params) do
    uuid_to_slug(UUIDv7.autogenerate())
  end

  @impl true
  def embed_as(format, _params), do: UUIDv7.embed_as(format)

  @impl true
  def equal?(a, b, _params), do: UUIDv7.equal?(a, b)
end
