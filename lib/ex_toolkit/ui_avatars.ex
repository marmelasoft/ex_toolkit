defmodule ExToolkit.UiAvatars do
  @moduledoc """
  A utility module to generate URLs for https://ui-avatars.com/ with customizable options.
  """

  import ExToolkit.Kernel, only: [validate_opts!: 2]

  @base_url "https://ui-avatars.com/api/"

  @type options :: %{
          optional(:size) => pos_integer(),
          optional(:font_size) => float(),
          optional(:length) => pos_integer(),
          optional(:name) => String.t(),
          optional(:rounded) => boolean(),
          optional(:bold) => boolean(),
          optional(:background) => String.t(),
          optional(:color) => String.t(),
          optional(:uppercase) => boolean(),
          optional(:format) => String.t()
        }

  @doc """
  Generates a UI Avatars image URL with the given options.

  ## Supported Options

    - `:name` – The name used to generate initials for the avatar.
    - `:length` – Number of characters in the initials (default: 2).
    - `:rounded` – Whether the avatar should be circular (default: `false`).
    - `:bold` – Whether the initials should be bold (default: `false`).
    - `:background` – Hex color for the background (default: `"f0e9e9"`).
    - `:color` – Hex color for the font (default: `"8b5d5d"`).
    - `:uppercase` – Whether the initials should be uppercased (default: `true`).
    - `:size` – Size of the image in pixels (default: `256`).
    - `:font_size` – Font size as a float percentage (default: `0.5`).
    - `:format` – The image format, `"svg"` or `"png"` (default: `"svg"`).

  ## Examples

      iex> UiAvatars.url(%{name: "Jane Doe", size: 128, rounded: true, format: "png", font_size: 1})
      "https://ui-avatars.com/api/?name=Jane+Doe&size=128&format=png&font-size=1&rounded=true"

      iex> UiAvatars.url(%{name: "Elixir", color: "ffffff", background: "000000", uppercase: false, bold: true})
      "https://ui-avatars.com/api/?name=Elixir&size=256&format=svg&uppercase=false&color=ffffff&font-size=0.5&background=000000&bold=true"

  """
  @spec url(options()) :: String.t()
  def url(opts \\ %{}) do
    opts =
      validate_opts!(opts, [
        :length,
        :name,
        :rounded,
        :bold,
        :background,
        :color,
        :uppercase,
        size: 256,
        font_size: 0.5,
        format: "svg"
      ])

    @base_url
    |> URI.merge("?#{encode_query(opts)}")
    |> URI.to_string()
  end

  defp encode_query(opts) do
    opts
    |> Map.put(:"font-size", opts[:font_size])
    |> Map.delete(:font_size)
    |> URI.encode_query()
  end

  @doc """
  Generates a Gravatar-compatible avatar URL that falls back to a UI Avatars image
  if the user has no Gravatar. For all supported options, see `url/1`.

  ## Examples

      iex> UiAvatars.gravatar_safe_url("john@example.com", name: "Jane Doe", background: "000000", color: "ffffff")
      "https://www.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?size=256&d=https%3A%2F%2Fui-avatars.com%2Fapi%2FJane+Doe/256/000000/ffffff/2/0.5/false/true/false/png"

      iex> UiAvatars.gravatar_safe_url("john@example.com", name: "João Oliveira", length: 3, font_size: 0.4)
      "https://www.gravatar.com/avatar/d4c74594d841139328695756648b6bd6?size=256&d=https%3A%2F%2Fui-avatars.com%2Fapi%2FJo%C3%A3o+Oliveira/256/f0e9e9/8b5d5d/3/0.4/false/true/false/png"
  """
  @spec gravatar_safe_url(String.t(), options()) :: String.t()
  def gravatar_safe_url(email, opts \\ %{}) do
    opts =
      validate_opts!(opts, [
        :name,
        size: 256,
        length: 2,
        background: "f0e9e9",
        color: "8b5d5d",
        font_size: 0.5,
        rounded: false,
        uppercase: true,
        bold: false,
        format: "png"
      ])

    options = %{
      default: URI.encode_www_form(@base_url) <> build_directories_url(opts)
    }

    "https://www.gravatar.com/avatar/#{encode_email(email)}?size=#{opts[:size]}&d=#{options[:default]}"
  end

  @subdirectories [
    :name,
    :size,
    :background,
    :color,
    :length,
    :font_size,
    :rounded,
    :uppercase,
    :bold,
    :format
  ]

  defp build_directories_url(opts) do
    Enum.map_join(@subdirectories, "/", fn
      :name ->
        opts
        |> Map.get(:name)
        |> URI.encode_www_form()

      key ->
        Map.get(opts, key)
    end)
  end

  defp encode_email(email) do
    email
    |> String.trim()
    |> String.downcase()
    |> then(&:crypto.hash(:md5, &1))
    |> Base.encode16(case: :lower)
  end
end
