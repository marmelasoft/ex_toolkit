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
      humanize = fn
        time_us when time_us < 1_000 -> "#{time_us} μs"
        time_us when time_us < 1_000_000 -> "#{Float.round(time_us / 1_000, 2)} ms"
        time_us -> "#{Float.round(time_us / 1_000_000, 2)} s"
      end

      {time, value} =
        :timer.tc(fn ->
          unquote(yield)
        end)

      IO.puts("Executed #{unquote(name)} in #{humanize.(time)}")

      value
    end
  end
end
