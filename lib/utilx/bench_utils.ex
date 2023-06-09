defmodule Utilx.BenchUtils do
  @moduledoc """
  Utility for quick and simple benchmarking functions in Elixir.
  """

  @doc """
  Benchmarks the execution time of a piece of code. It should be used only in
  really simple cases.

  ## Examples

    iex> timeit "Sleep for a while", do: :timer.sleep(1000)
    Executed Sleep for a while in 1.00 seconds
  """
  defmacro timeit(name, do: yield) do
    quote do
      {time, value} =
        :timer.tc(fn ->
          unquote(yield)
        end)

      IO.puts("Executed #{unquote(name)} in #{humanize(time)}")

      value
    end
  end

  defp humanize(time_us) when time_us < 1_000, do: "#{time_us} μs"

  defp humanize(time_us) when time_us < 1_000_000, do: "#{Float.round(time_us / 1_000, 2)} ms"

  defp humanize(time_us), do: "#{Float.round(time_us / 1_000_000, 2)} s"
end
