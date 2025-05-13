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

  ## Examples

      iex> UiAvatars.url(%{name: "Jane Doe", size: 128, rounded: true, format: "png", "font-size": 1})
      "https://ui-avatars.com/api/?name=Jane+Doe&size=128&format=png&rounded=true&font-size=1"

      iex> UiAvatars.url(%{name: "Elixir", color: "ffffff", background: "000000", uppercase: false, bold: true})
      "https://ui-avatars.com/api/?name=Elixir&size=256&format=svg&uppercase=false&color=ffffff&bold=true&background=000000&font-size=0.5"

  """
  @spec url(options()) :: String.t()
  def url(opts \\ %{}) do

    opts = validate_opts!(opts, [:length, :name, :rounded, :bold, :background, :color, :uppercase, size: 256, "font-size": 0.5, format: "svg"])

    @base_url
    |> URI.merge("?#{URI.encode_query(opts)}")
    |> URI.to_string()
  end
end
