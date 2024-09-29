defmodule ExToolkit.NamingTest do
  use ExUnit.Case, async: true

  alias ExToolkit.Naming

  doctest Naming

  tests = [
    # test name, input, initials, first and last name
    {"nil does not crash", nil, "", ""},
    {"when it is empty", "", "", ""},
    {"when has only one name", "Nelson", "N", "Nelson"},
    {"when has two names", "Nelson Estevão", "NE", "Nelson Estevão"},
    {"when has unwanted spaces", "Nelson    Estevão  ", "NE", "Nelson Estevão"},
    {"when it is full name", "Nelson Miguel Araújo Felício", "NF", "Nelson Felício"},
    {"when it is full name and not capitalize", "nelson miguel araújo felício", "NF",
     "Nelson Felício"},
    {"when it is full name with extra info in ()", "nelson araújo felício (Marmelasoft)", "NF",
     "Nelson Felício"},
    {"when it is a number", "12312 2123 1", "", ""},
    {"when there are leading spaces", "  Nelson Estevão", "NE", "Nelson Estevão"},
    {"when there are trailing spaces", "Nelson Estevão  ", "NE", "Nelson Estevão"},
    {"when there are spaces around", "  Nelson Miguel Estevão  ", "NE", "Nelson Estevão"}
  ]

  describe "#extract_initials/1" do
    for {description, input, expected, _first_last_name} <- tests do
      test description do
        assert Naming.extract_initials(unquote(input)) == unquote(expected)
      end
    end
  end

  describe "#extract_first_last_name/1" do
    for {description, input, _initials, expected} <- tests do
      test description do
        assert Naming.extract_first_last_name(unquote(input)) == unquote(expected)
      end
    end
  end

  describe "extract_short_name/1" do
    test "special caracters are completly ignored" do
      assert Naming.extract_short_name("()&12[]%,.!@#$%^&*()_+{}|:;") == ""
    end
  end
end
