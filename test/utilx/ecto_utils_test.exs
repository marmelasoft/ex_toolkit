defmodule Utilx.EctoUtilsTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  import Ecto.Query

  alias Utilx.EctoUtils

  doctest EctoUtils

  test "if an invalid option is used a log message should be displayed" do
    assert capture_log(fn ->
             EctoUtils.apply_options(from(u in "users"), non_option: "not real")
           end) =~ "option :non_option is invalid and being ignored"
  end
end
