defmodule ExToolkit.Map do
  @moduledoc """
  This module provides utilities for working with maps.
  """

  @doc """
  Recursively converts a struct into a plain map, transforming all nested structs,
  maps, and lists along the way.

  Only accepts a struct at the top level. If a non-struct is passed, it will raise a `FunctionClauseError`.

  If you don't want to do a deep recursive conversion you should use `Map.from_struct/1`.

  ## Examples

      iex> outer = %URI{host: "test", scheme: %{info: %URI{host: 42, authority: nil, fragment: nil, path: nil, port: nil, query: nil, scheme: nil, userinfo: nil}}}
      iex> ExToolkit.Map.deep_from_struct(outer)
      %{
        host: "test",
        scheme: %{info: %{host: 42, authority: nil, fragment: nil, path: nil, port: nil, query: nil, scheme: nil, userinfo: nil}},
        authority: nil,
        fragment: nil,
        path: nil,
        port: nil,
        query: nil,
        userinfo: nil
      }

  """
  @spec deep_from_struct(struct()) :: map()
  def deep_from_struct(data) when is_struct(data) do
    data
    |> Map.from_struct()
    |> Map.new(fn {k, v} -> {k, do_deep_from_struct(v)} end)
  end

  defp do_deep_from_struct(data) when is_struct(data), do: deep_from_struct(data)

  defp do_deep_from_struct(map) when is_map(map) do
    Map.new(map, fn {k, v} -> {k, do_deep_from_struct(v)} end)
  end

  defp do_deep_from_struct(list) when is_list(list) do
    Enum.map(list, &do_deep_from_struct/1)
  end

  defp do_deep_from_struct(other), do: other
end
