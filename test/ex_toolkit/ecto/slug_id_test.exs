defmodule ExToolkit.Ecto.SlugIDTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias ExToolkit.Ecto.SlugID
  alias Uniq.UUID

  defmodule TestSchema do
    @moduledoc false
    use Ecto.Schema

    @primary_key {:id, SlugID, autogenerate: true}
    @foreign_key_type SlugID

    schema "test" do
      belongs_to(:test, TestSchema)
    end
  end

  @test_prefixed_uuid "3TUIKuXX5mNO2jSA41bsDx"
  @test_uuid UUID.to_string("7232b37d-fc13-44c0-8e1b-9a5a07e24921", :raw)
  @test_prefixed_uuid_with_leading_zero "02tREKF6r6OCO2sdSjpyTm"
  @test_uuid_with_leading_zero UUID.to_string("0188a516-bc8c-7c5a-9b68-12651f558b9e", :raw)
  @test_prefixed_uuid_null "0000000000000000000000"
  @test_uuid_null UUID.to_string("00000000-0000-0000-0000-000000000000", :raw)
  @test_prefixed_uuid_invalid_characters String.duplicate(".", 32)
  @test_uuid_invalid_characters String.duplicate(".", 22)
  @test_prefixed_uuid_invalid_format String.duplicate("x", 31)
  @test_uuid_invalid_format String.duplicate("x", 21)

  test "cast/1" do
    assert SlugID.cast(@test_prefixed_uuid) == {:ok, @test_prefixed_uuid}

    assert SlugID.cast(@test_prefixed_uuid_with_leading_zero) ==
             {:ok, @test_prefixed_uuid_with_leading_zero}

    assert SlugID.cast(@test_prefixed_uuid_null) == {:ok, @test_prefixed_uuid_null}
    assert SlugID.cast(nil) == {:ok, nil}
    assert SlugID.cast(@test_prefixed_uuid_invalid_characters) == :error
    assert SlugID.cast(@test_prefixed_uuid_invalid_format) == :error
    assert SlugID.cast(@test_prefixed_uuid) == {:ok, @test_prefixed_uuid}
  end

  test "load/1" do
    assert SlugID.load(@test_uuid) == {:ok, @test_prefixed_uuid}

    assert SlugID.load(@test_uuid_with_leading_zero) ==
             {:ok, @test_prefixed_uuid_with_leading_zero}

    assert SlugID.load(@test_uuid_null) == {:ok, @test_prefixed_uuid_null}
    assert SlugID.load(@test_uuid_invalid_characters) == :error
    assert SlugID.load(@test_uuid_invalid_format) == :error
    assert SlugID.load(@test_prefixed_uuid) == :error
    assert SlugID.load(nil) == {:ok, nil}
    assert SlugID.load(@test_uuid) == {:ok, @test_prefixed_uuid}
  end

  test "dump/1" do
    assert SlugID.dump(@test_prefixed_uuid) == {:ok, @test_uuid}

    assert SlugID.dump(@test_prefixed_uuid_with_leading_zero) ==
             {:ok, @test_uuid_with_leading_zero}

    assert SlugID.dump(@test_prefixed_uuid_null) == {:ok, @test_uuid_null}
    assert SlugID.dump(@test_uuid) == :error
    assert SlugID.dump(nil) == {:ok, nil}
    assert SlugID.dump(@test_prefixed_uuid) == {:ok, @test_uuid}
  end

  test "autogenerate/0" do
    assert prefixed_uuid = SlugID.autogenerate()
    assert {:ok, uuid} = SlugID.dump(prefixed_uuid)
    assert {:ok, %UUID{format: :raw, version: 7}} = UUID.parse(uuid)
  end

  test "embed_as/1" do
    assert :self = SlugID.embed_as(:raw)
  end

  test "equal/1" do
    assert SlugID.equal?(@test_uuid, @test_uuid)
    refute SlugID.equal?(@test_uuid, @test_uuid_null)
  end
end
