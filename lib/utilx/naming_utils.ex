defmodule Utilx.NamingUtils do
  @moduledoc """
  This module encapsulates common tasks related to processing personal names in
  a standardized format. This module treats names as case-insensitive and
  returns results in a formatted, readable way.
  """

  @doc """
  Shortens the first name to its initial, while preserving the rest of the name.

  This function takes a name (a string of one or more words), and reduces the first name to its initial.
  The rest of the name is preserved. The initial is followed by a period and a space, and then the rest of the name.

  ## Parameters

  - `name`: A string representing a full name, or `nil`.

  ## Examples

      iex> NamingUtils.shorten_firstname(nil)
      ""

      iex> NamingUtils.shorten_firstname("")
      ""

      iex> NamingUtils.shorten_firstname("John")
      "J."

      iex> NamingUtils.shorten_firstname("john")
      "J."

      iex> NamingUtils.shorten_firstname("John Doe")
      "J. Doe"

      iex> NamingUtils.shorten_firstname("john doe")
      "J. Doe"

      iex> NamingUtils.shorten_firstname("john doe jr")
      "J. Doe Jr"
  """
  @spec shorten_firstname(nil | String.t()) :: String.t()
  def shorten_firstname(name) when is_nil(name) or name == "", do: ""

  def shorten_firstname(name) do
    case String.split(name, " ", parts: 2) do
      [first] ->
        [letter | _rest] = String.codepoints(first)
        "#{String.upcase(letter)}."

      [first, rest] ->
        [letter | _rest] = String.codepoints(first)
        "#{String.upcase(letter)}. #{capitalize(rest)}"
    end
  end

  @doc """
  Extracts the initials from a given name.

  This function takes a name (a string of one or more words), and extracts the
  first letter of the first name and the family name.

  ## Parameters

  - `name`: A string representing a full name, or `nil`.

  ## Examples

      iex> NamingUtils.extract_initials(nil)
      ""

      iex> NamingUtils.extract_initials("")
      ""

      iex> NamingUtils.extract_initials("John")
      "J"

      iex> NamingUtils.extract_initials("John Doe")
      "JD"

      iex> NamingUtils.extract_initials("John Nommensen Duchac")
      "JD"
  """
  @spec extract_initials(nil | String.t()) :: String.t()
  def extract_initials(name) when is_nil(name) or name == "", do: ""

  def extract_initials(name) do
    initials =
      name
      |> String.trim()
      |> String.split(" ")
      |> Stream.map(&String.first/1)
      |> Stream.filter(&(&1 != "" and not is_nil(&1)))
      |> Stream.map(&String.trim/1)
      |> Stream.filter(&String.match?(&1, ~r/^\p{L}$/u))
      |> Enum.map(&String.upcase/1)

    case initials do
      [] -> ""
      [first] -> first
      [first | rest] -> first <> Enum.at(rest, -1)
    end
  end

  @doc """
  Extracts and capitalizes the first and last names from a given name.

  ## Parameters

  - `name`: A string representing a full name, or `nil`.

  ## Examples

      iex> NamingUtils.extract_first_last_name(nil)
      ""

      iex> NamingUtils.extract_first_last_name("")
      ""

      iex> NamingUtils.extract_first_last_name("john")
      "John"

      iex> NamingUtils.extract_first_last_name("john doe smith")
      "John Smith"
  """
  @spec extract_first_last_name(nil | String.t()) :: String.t()
  def extract_first_last_name(name) when is_nil(name) or name == "", do: ""

  def extract_first_last_name(name) do
    names =
      name
      |> String.trim()
      |> String.split(" ")
      |> Stream.filter(&String.match?(String.slice(&1, 0, 1), ~r/^\p{L}$/u))
      |> Enum.map(&String.capitalize/1)

    case names do
      [] -> ""
      [first] -> first
      [first | rest] -> first <> " " <> Enum.at(rest, -1)
    end
  end

  @doc """
  Capitalizes the first letter of each word in a name.

  ## Parameters

  - `name`: A string representing a full name, or `nil`.

  ## Examples

      iex> NamingUtils.capitalize(nil)
      ""

      iex> NamingUtils.capitalize("")
      ""

      iex> NamingUtils.capitalize("john doe")
      "John Doe"

      iex> NamingUtils.capitalize("JOHN DOE")
      "John Doe"

      iex> NamingUtils.capitalize("john nommensen duchac")
      "John Nommensen Duchac"
  """
  @spec capitalize(nil | String.t()) :: String.t()
  def capitalize(name) when is_nil(name) or name == "", do: ""

  def capitalize(name) do
    name
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
