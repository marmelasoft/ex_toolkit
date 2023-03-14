defmodule Utilx.BenchUtils do
  require Timex

  defmacro timeit(name, do: yield) do
    quote do
      {time, value} =
        :timer.tc(fn ->
          unquote(yield)
        end)

      time_humanized =
        Timex.Duration.from_seconds(time / 1_000_000)
        |> Timex.Format.Duration.Formatter.format(:humanized)

      IO.puts("Executed #{unquote(name)} in #{time_humanized}")

      value
    end
  end
end
