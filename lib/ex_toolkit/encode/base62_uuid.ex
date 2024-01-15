defmodule ExToolkit.Encode.Base62UUID do
  @moduledoc """
  A utility module providing functions to encode and decode UUIDs using Base62 encoding.

  The Base62 encoding allows representing UUIDs in a more compact form, reducing their length from 32 to 22 characters.
  This module supports converting standard UUIDs (as strings) to Base62 encoded UUIDs and vice-versa.
  """

  @base62_uuid_length 22
  @uuid_length 32

  @doc """
  Encodes a UUID into a Base62 encoded string.

  ## Examples

      iex> Base62UUID.encode("49d3793a-2f87-4bcb-aa96-be5892848ae0")
      "2FJ5BAFmLzL78YNqBSsS9I"
  """
  @spec encode(String.t()) :: String.t()
  def encode(uuid) when is_binary(uuid) do
    uuid
    |> String.replace("-", "")
    |> String.to_integer(16)
    |> Base62.encode()
    |> String.pad_leading(@base62_uuid_length, "0")
  end

  @doc """
  Decodes a Base62 encoded string into a UUID.

  This function is the inverse of `encode/1`. It converts a Base62 encoded string back to its original UUID form.

  ## Examples

      iex> Base62UUID.decode("2FJ5BAFmLzL78YNqBSsS9I")
      {:ok, "49d3793a-2f87-4bcb-aa96-be5892848ae0"}

  """
  @spec decode(String.t()) :: {:ok | :error, String.t()}
  def decode(string) when is_binary(string) do
    with {:ok, number} <- Base62.decode(string) do
      to_uuid(number)
    end
  end

  defp to_uuid(number) when is_integer(number) do
    number
    |> Integer.to_string(16)
    |> String.downcase()
    |> String.pad_leading(@uuid_length, "0")
    |> case do
      <<g1::binary-size(8), g2::binary-size(4), g3::binary-size(4), g4::binary-size(4),
        g5::binary-size(12)>> ->
        {:ok, "#{g1}-#{g2}-#{g3}-#{g4}-#{g5}"}

      other ->
        {:error, "invalid UUID: #{inspect(other)}"}
    end
  end
end
