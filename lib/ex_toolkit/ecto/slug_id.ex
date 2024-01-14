defmodule ExToolkit.Ecto.SlugID do
  @moduledoc """
  A Ecto type that facilitates the generation of prefixed base62 encoded UUIDv7
  for use as primary and foreign keys in Ecto schemas.

  ## Examples

      @primary_key {:id, ExToolkit.Ecto.SlugID, autogenerate: true}
      @foreign_key_type ExToolkit.Ecto.SlugID
  """
  use Ecto.Type

  alias ExToolkit.Encode.Base62UUID

  @impl true
  def type, do: :uuid

  @impl true
  def cast(nil), do: {:ok, nil}

  def cast(slug) do
    with {:ok, _uuid} <- slug_to_uuid(slug) do
      {:ok, slug}
    else
      _ -> :error
    end
  end

  @impl true
  def load(nil), do: {:ok, nil}

  def load(data) do
    case UUIDv7.load(data) do
      {:ok, uuid} -> {:ok, uuid_to_slug(uuid)}
      :error -> :error
    end
  end

  @impl true
  def dump(nil), do: {:ok, nil}

  def dump(slug) do
    case slug_to_uuid(slug) do
      {:ok, uuid} -> UUIDv7.dump(uuid)
      :error -> :error
    end
  end

  @impl true
  def autogenerate() do
    uuid_to_slug(UUIDv7.autogenerate())
  end

  def generate(), do: autogenerate()

  @impl true
  def embed_as(format), do: UUIDv7.embed_as(format)

  @impl true
  def equal?(a, b), do: UUIDv7.equal?(a, b)

  defp slug_to_uuid(slug) do
    with {:ok, uuid} <- Base62UUID.decode(slug) do
      {:ok, uuid}
    else
      _ -> :error
    end
  end

  defp uuid_to_slug(uuid), do: Base62UUID.encode(uuid)
end
