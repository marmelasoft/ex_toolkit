defmodule ExToolkit.Ecto.Paginator do
  import Ecto.Query, only: [exclude: 2]
  import ExToolkit.Ecto.Query, only: [apply_pagination: 3]
  import ExToolkit.Kernel, only: [validate_opts!: 2]

  @max_page_size 100

  defmacro __using__(opts \\ []) do
    quote do
      @paginator_defaults unquote(opts)

      def paginate(queryable, page, opts \\ [], repo_opts \\ []) do
        opts = Keyword.merge(@paginator_defaults, opts)

        ExToolkit.Ecto.Paginator.paginate(queryable, __MODULE__, page, opts, repo_opts)
      end
    end
  end

  @type option :: {:page_size, non_neg_integer()}
  @type options :: [option]

  @type page :: %{
          data: list(any()),
          current_page: non_neg_integer(),
          total_pages: non_neg_integer(),
          total_count: non_neg_integer(),
          has_next_page: boolean(),
          has_prev_page: boolean(),
          is_first_page: boolean(),
          is_last_page: boolean()
        }

  @type page(elem) :: %{
          data: list(elem),
          current_page: non_neg_integer(),
          total_pages: non_neg_integer(),
          total_count: non_neg_integer(),
          has_next_page: boolean(),
          has_prev_page: boolean(),
          is_first_page: boolean(),
          is_last_page: boolean()
        }

  @spec paginate(Ecto.Queryable.t(), Ecto.Repo.t(), pos_integer(), options(), keyword()) :: page()
  def paginate(queryable, repo, page, opts \\ [], repo_opts \\ []) do
    %{page_size: page_size} = validate_opts!(opts, page_size: 25)
    page_size = sanitize_page_size(page_size)
    current_page = sanitize_page(page)

    total_count = calculate_total_count(queryable, repo)
    total_pages = calculate_total_pages(total_count, page_size)

    data =
      queryable
      |> apply_pagination(current_page, page_size)
      |> repo.all(repo_opts)

    %{
      data: data,
      current_page: current_page,
      total_count: total_count,
      total_pages: total_pages,
      has_next_page: current_page < total_pages,
      has_prev_page: current_page > 1,
      is_first_page: current_page == 1,
      is_last_page: current_page >= total_pages
    }
  end

  defp calculate_total_count(queryable, repo) do
    queryable
    |> exclude(:order_by)
    |> repo.aggregate(:count)
  end

  defp calculate_total_pages(total_count, page_size), do: ceil(total_count / page_size)

  defp sanitize_page_size(page_size) when is_binary(page_size),
    do: page_size |> String.to_integer() |> sanitize_page_size()

  defp sanitize_page_size(page_size) when page_size > @max_page_size, do: @max_page_size
  defp sanitize_page_size(page_size), do: page_size

  defp sanitize_page(page) when is_binary(page),
    do: page |> String.to_integer() |> sanitize_page()

  defp sanitize_page(page) when page <= 0, do: 1

  defp sanitize_page(page), do: page
end
