defmodule ExToolkit.EctoTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  import Ecto.Query

  import ExToolkit.Ecto

  doctest ExToolkit.Ecto

  test "if an invalid option is used a log message should be displayed" do
    assert capture_log(fn ->
             apply_options(from(u in "users"), non_option: "not real")
           end) =~ "option :non_option is invalid and being ignored"
  end

  test "if an invalid option is used with sanitize options a log message should not be displayed" do
    assert capture_log(fn ->
             apply_options(from(u in "users"), sanitize_options(non_option: "not real"))
           end) =~ ""
  end
end
