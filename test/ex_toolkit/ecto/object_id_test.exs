defmodule ExToolkit.Ecto.ObjectIDTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias ExToolkit.Ecto.ObjectID
  alias Uniq.UUID

  defmodule TestSchema do
    @moduledoc false
    use Ecto.Schema

    @primary_key {:id, ObjectID, prefix: "test", autogenerate: true}
    @foreign_key_type ObjectID

    schema "test" do
      belongs_to(:test, TestSchema)
    end
  end

  @params ObjectID.init(
            schema: TestSchema,
            field: :id,
            primary_key: true,
            autogenerate: true,
            prefix: "test"
          )
  @belongs_to_params ObjectID.init(schema: TestSchema, field: :test, foreign_key: :test_id)
  @loader nil
  @dumper nil

  @test_prefixed_uuid "test_3TUIKuXX5mNO2jSA41bsDx"
  @test_uuid UUID.to_string("7232b37d-fc13-44c0-8e1b-9a5a07e24921", :raw)
  @test_prefixed_uuid_with_leading_zero "test_02tREKF6r6OCO2sdSjpyTm"
  @test_uuid_with_leading_zero UUID.to_string("0188a516-bc8c-7c5a-9b68-12651f558b9e", :raw)
  @test_prefixed_uuid_null "test_0000000000000000000000"
  @test_uuid_null UUID.to_string("00000000-0000-0000-0000-000000000000", :raw)
  @test_prefixed_uuid_invalid_characters "test_" <> String.duplicate(".", 32)
  @test_uuid_invalid_characters String.duplicate(".", 22)
  @test_prefixed_uuid_invalid_format "test_" <> String.duplicate("x", 31)
  @test_uuid_invalid_format String.duplicate("x", 21)

  test "cast/2" do
    assert ObjectID.cast(@test_prefixed_uuid, @params) == {:ok, @test_prefixed_uuid}

    assert ObjectID.cast(@test_prefixed_uuid_with_leading_zero, @params) ==
             {:ok, @test_prefixed_uuid_with_leading_zero}

    assert ObjectID.cast(@test_prefixed_uuid_null, @params) == {:ok, @test_prefixed_uuid_null}
    assert ObjectID.cast(nil, @params) == {:ok, nil}
    assert ObjectID.cast("otherprefix" <> @test_prefixed_uuid, @params) == :error
    assert ObjectID.cast(@test_prefixed_uuid_invalid_characters, @params) == :error
    assert ObjectID.cast(@test_prefixed_uuid_invalid_format, @params) == :error
    assert ObjectID.cast(@test_prefixed_uuid, @belongs_to_params) == {:ok, @test_prefixed_uuid}
  end

  test "load/3" do
    assert ObjectID.load(@test_uuid, @loader, @params) == {:ok, @test_prefixed_uuid}

    assert ObjectID.load(@test_uuid_with_leading_zero, @loader, @params) ==
             {:ok, @test_prefixed_uuid_with_leading_zero}

    assert ObjectID.load(@test_uuid_null, @loader, @params) == {:ok, @test_prefixed_uuid_null}
    assert ObjectID.load(@test_uuid_invalid_characters, @loader, @params) == :error
    assert ObjectID.load(@test_uuid_invalid_format, @loader, @params) == :error
    assert ObjectID.load(@test_prefixed_uuid, @loader, @params) == :error
    assert ObjectID.load(nil, @loader, @params) == {:ok, nil}
    assert ObjectID.load(@test_uuid, @loader, @belongs_to_params) == {:ok, @test_prefixed_uuid}
  end

  test "dump/3" do
    assert ObjectID.dump(@test_prefixed_uuid, @dumper, @params) == {:ok, @test_uuid}

    assert ObjectID.dump(@test_prefixed_uuid_with_leading_zero, @dumper, @params) ==
             {:ok, @test_uuid_with_leading_zero}

    assert ObjectID.dump(@test_prefixed_uuid_null, @dumper, @params) == {:ok, @test_uuid_null}
    assert ObjectID.dump(@test_uuid, @dumper, @params) == :error
    assert ObjectID.dump(nil, @dumper, @params) == {:ok, nil}
    assert ObjectID.dump(@test_prefixed_uuid, @dumper, @belongs_to_params) == {:ok, @test_uuid}
  end

  test "autogenerate/1" do
    assert prefixed_uuid = ObjectID.autogenerate(@params)
    assert {:ok, uuid} = ObjectID.dump(prefixed_uuid, nil, @params)
    assert {:ok, %UUID{format: :raw, version: 7}} = UUID.parse(uuid)
  end

  test "embed_as/2" do
    assert :self = ObjectID.embed_as(:raw, @params)
  end

  test "equal/2" do
    assert ObjectID.equal?(@test_uuid, @test_uuid, @params)
  end
end
