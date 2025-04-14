defmodule ExToolkit.Ecto.PaginatorTest do
  use ExUnit.Case, async: true

  import Ecto.Query
  alias ExToolkit.TestRepo

  defmodule Post do
    use Ecto.Schema

    schema "posts" do
      field(:title, :string)
      timestamps()
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.checkin(TestRepo) end)
    :ok
  end

  test "default page size is 25" do
    insert_posts(26)

    assert %{data: data} = TestRepo.paginate(query(), 1)

    assert Enum.count(data) == 25
  end

  test "allow page as string" do
    insert_posts(3)

    assert %{current_page: current_page} = TestRepo.paginate(query(), "2", page_size: 1)

    assert current_page == 2
  end

  test "allow page_size as string" do
    insert_posts(3)

    assert %{current_page: current_page, total_pages: total_pages} =
             TestRepo.paginate(query(), 1, page_size: "1")

    assert current_page == 1
    assert total_pages == 3
  end

  test "allow page_size as nil" do
    insert_posts(3)

    assert %{current_page: current_page, total_pages: total_pages} =
             TestRepo.paginate(query(), 1, page_size: nil)

    assert current_page == 1
    assert total_pages == 1
  end

  test "when page_size is too big, it is capped to max page size" do
    insert_posts(101)

    assert %{current_page: current_page, total_pages: total_pages} =
             TestRepo.paginate(query(), 1, page_size: 150)

    assert current_page == 1
    assert total_pages == 2
  end

  test "total count gives number of existing rows" do
    insert_posts(10)

    assert %{data: data, total_count: total_count} = TestRepo.paginate(query(), 1, page_size: 5)

    assert Enum.count(data) == 5
    assert total_count == 10
  end

  test "has next page is true when there are more pages" do
    insert_posts(3)

    assert %{has_next_page: true} = TestRepo.paginate(query(), 1, page_size: 2)
  end

  test "has next page is false when there are no more pages" do
    insert_posts(1)

    assert %{has_next_page: false} = TestRepo.paginate(query(), 1, page_size: 2)
  end

  test "has prev page is true when we are not on the first page" do
    insert_posts(3)

    assert %{has_prev_page: true} = TestRepo.paginate(query(), 2, page_size: 2)
  end

  test "has prev page is false when we are on the first page" do
    insert_posts(1)

    assert %{has_next_page: false} = TestRepo.paginate(query(), 1, page_size: 2)
  end

  test "is first page true when we are on the first page" do
    insert_posts(1)

    assert %{is_first_page: true} = TestRepo.paginate(query(), 1, page_size: 2)
  end

  test "is last page true when we are on the last page" do
    insert_posts(1)

    assert %{is_last_page: true} = TestRepo.paginate(query(), 1, page_size: 2)
  end

  defp insert_posts(n) do
    for i <- 1..n do
      %Post{title: "Post #{i}"}
      |> TestRepo.insert!()
    end
  end

  defp query do
    from(post in Post)
  end
end
