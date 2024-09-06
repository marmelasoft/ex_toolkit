defmodule ExToolkit.Ecto.Changeset do
  @moduledoc """
  Helper functions that extend `Ecto.Changeset` functionality.
  """

  import Ecto.Changeset

  # Taken from here https://mathiasbynens.be/demo/url-regex
  @http_regex ~r/^(?:(?:https?):\/\/)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\x{00a1}-\x{ffff}0-9]+-?)*[a-z\x{00a1}-\x{ffff}0-9]+)(?:\.(?:[a-z\x{00a1}-\x{ffff}0-9]+-?)*[a-z\x{00a1}-\x{ffff}0-9]+)*(?:\.(?:[a-z\x{00a1}-\x{ffff}]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?$/ius

  @doc """
  Validates the structure of a URL field in an Ecto changeset. It does not make it required field.

  If the `field` in the `changeset` is a URL, this function ensures that it has a scheme (defaulting to "https://" if
  none is present), and then checks the URL's structure against a regular expression.

  If the URL's structure is invalid, the `error_message` is attached to the `field` in the `changeset`'s errors.

  ## Parameters

    - `changeset`: The Ecto changeset containing the URL to validate.
    - `field`: The key (atom) for the field in the changeset containing the URL.
    - `error_message`: The error message to attach to the `field` in the `changeset` if the URL is invalid.

  ## Examples

      iex> types = %{url: :string}
      iex> params = %{url: "https://www.example.com/"}
      iex> Ecto.Changeset.cast({%{}, types}, params, Map.keys(types))
      ...> |> validate_url(:url, "is not a valid url")
      #Ecto.Changeset<action: nil, changes: %{url: "https://www.example.com/"}, errors: [], data: %{}, valid?: true, ...>

      iex> types = %{url: :string}
      iex> params = %{url: "www.example.com/"}
      iex> Ecto.Changeset.cast({%{}, types}, params, Map.keys(types))
      ...> |> validate_url(:url, "is not a valid url")
      #Ecto.Changeset<action: nil, changes: %{url: "https://www.example.com/"}, errors: [], data: %{}, valid?: true, ...>

      iex> types = %{url: :string}
      iex> params = %{url: nil}
      iex> Ecto.Changeset.cast({%{}, types}, params, Map.keys(types))
      ...> |> validate_url(:url, "is not a valid url")
      #Ecto.Changeset<action: nil, changes: %{}, errors: [], data: %{}, valid?: true, ...>

      iex> types = %{url: :string}
      iex> params = %{url: "some@invalid_url"}
      iex> Ecto.Changeset.cast({%{}, types}, params, Map.keys(types))
      ...> |> validate_url(:url, "is not a valid url")
      #Ecto.Changeset<action: nil, changes: %{url: "https://some@invalid_url"}, errors: [url: {"is not a valid url", [validation: :format]}], data: %{}, valid?: false, ...>

      iex> types = %{url: :string}
      iex> params = %{url: "Just some random text"}
      iex> Ecto.Changeset.cast({%{}, types}, params, Map.keys(types))
      ...> |> validate_url(:url, "is not a valid url")
      #Ecto.Changeset<action: nil, changes: %{url: "https://Just some random text"}, errors: [url: {"is not a valid url", [validation: :format]}], data: %{}, valid?: false, ...>
  """
  def validate_url(changeset, field, error_message) do
    changeset
    |> ensure_url_scheme(field)
    |> validate_format(field, @http_regex, message: error_message)
  end

  defp ensure_url_scheme(changeset, field) do
    changeset
    |> get_field(field)
    |> do_ensure_url_scheme()
    |> then(&put_change(changeset, field, &1))
  end

  defp do_ensure_url_scheme(nil), do: nil

  defp do_ensure_url_scheme(url) do
    case URI.parse(url) do
      %URI{scheme: nil} -> "https://#{url}"
      _ -> url
    end
  end
end
