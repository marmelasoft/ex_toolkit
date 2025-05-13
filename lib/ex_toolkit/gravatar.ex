defmodule ExToolkit.Gravatar do
  @moduledoc """
  Interface to Gravatar API.

  See [Gravatar API documentation](https://docs.gravatar.com/api/avatars/images/) to learn more.
  """

  import ExToolkit.Kernel, only: [validate_opts!: 2]

  @type avatar_options :: %{
          optional(:size) => pos_integer(),
          optional(:default) => String.t(),
          optional(:rating) => String.t(),
          optional(:initials) => String.t(),
          optional(:name) => String.t()
        }

  @doc """
  Generates a Gravatar image URL for the given email address.

  ## Options

    * `:size` - size of the image (1..2048), default: 256
    * `:default` - a URL-encoded image or one of: initials, color, 404, mp, identicon, monsterid, wavatar, retro, robohash or blank, default: mm
    * `:rating` - rating (g, pg, r, x), default: g
    * `:initials` - initials for the initials default
    * `:name` - name to generate initials

  ## Examples

      iex> avatar_url("john@example.com")
      "https://www.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?d=mm&s=256&r=g"

      iex> avatar_url("john@example.com", size: 128)
      "https://www.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?d=mm&s=128&r=g"

      iex> avatar_url("john@example.com", default: "identicon")
      "https://www.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?d=identicon&s=256&r=g"

      iex> avatar_url("john@example.com", default: "https://example.com/avatar.png")
      "https://www.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?d=https%3A%2F%2Fexample.com%2Favatar.png&s=256&r=g"
  """
  @spec avatar_url(String.t(), avatar_options()) :: String.t()
  def avatar_url(email, opts \\ %{}) do
    opts = validate_opts!(opts, [:name, :initials, size: 256, default: "mm", rating: "g"])

    "https://www.gravatar.com/avatar/#{encode_email(email)}"
    |> URI.merge("?#{encode_query(opts)}")
    |> URI.to_string()
  end

  defp encode_email(email) do
    email
    |> String.trim()
    |> String.downcase()
    |> then(&:crypto.hash(:md5, &1))
    |> Base.encode16(case: :lower)
  end

  @key_aliases %{default: :d, size: :s, rating: :r}

  defp encode_query(opts) do
    opts
    |> Enum.map(fn {k, v} -> {Map.get(@key_aliases, k, k), v} end)
    |> URI.encode_query()
  end
end
