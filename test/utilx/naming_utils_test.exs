defmodule Utilx.NamingUtilsTest do
  use ExUnit.Case, async: true

  alias Utilx.NamingUtils

  doctest NamingUtils

  describe "#extract_initials/1" do
    test "nil does not crash" do
      assert NamingUtils.extract_initials(nil) == ""
    end

    test "when it is empty" do
      assert NamingUtils.extract_initials("") == ""
    end

    test "when has only one name" do
      assert NamingUtils.extract_initials("Nelson") == "N"
    end

    test "when has two names" do
      assert NamingUtils.extract_initials("Nelson Estevão") == "NE"
    end

    test "when it is a full name" do
      assert NamingUtils.extract_initials("Nelson Miguel Araújo Felício") == "NF"
    end

    test "when it is a full name and not capitalize" do
      assert NamingUtils.extract_initials("nelson miguel araújo felício") == "NF"
    end

    test "when it is a full name with extra info in ()" do
      assert NamingUtils.extract_initials("nelson miguel araújo felício (Marmelasoft)") == "NF"
    end

    test "when it is a number" do
      assert NamingUtils.extract_initials("12312 2123 1") == ""
    end
  end

  describe "#extract_first_last_name/1" do
    test "nil does not crash" do
      assert NamingUtils.extract_first_last_name(nil) == ""
    end

    test "when it is empty" do
      assert NamingUtils.extract_first_last_name("") == ""
    end

    test "when has only one name" do
      assert NamingUtils.extract_first_last_name("Nelson") == "Nelson"
    end

    test "when has two names" do
      assert NamingUtils.extract_first_last_name("Nelson Estevão") == "Nelson Estevão"
    end

    test "when has unwated spaces" do
      assert NamingUtils.extract_first_last_name("Nelson    Estevão  ") == "Nelson Estevão"
    end

    test "when it is a number" do
      assert NamingUtils.extract_first_last_name("12312 2123 1") == ""
    end

    test "when it is a full name" do
      assert NamingUtils.extract_first_last_name("Nelson Miguel de Oliveira Estevão") ==
               "Nelson Estevão"
    end

    test "when it is a full name and not capitalize" do
      assert NamingUtils.extract_first_last_name("nelson miguel de oliveira estevão") ==
               "Nelson Estevão"
    end

    test "when it is a full name with extra info in ()" do
      assert NamingUtils.extract_first_last_name("nelson araújo felício (Marmelasoft)") ==
               "Nelson Felício"
    end
  end
end
