defmodule ExToolkit.Ecto.Paginator do
  @moduledoc """
  Provides functionality for paginating Ecto queries. It offers a simple and
  flexible way to paginate large result sets, supporting both default and
  custom pagination options.

  ## Usage

  To use this paginator in your module, you call `use ExToolkit.Ecto.Paginator`.

      defmodule MyApp.Repo do
        use Ecto.Repo, otp_app: :my_app
        use ExToolkit.Ecto.Paginator
      end

  The default page size is 25 but you can override it by passing a `page_size`.

      defmodule MyApp.Repo do
        use Ecto.Repo, otp_app: :my_app
        use ExToolkit.Ecto.Paginator, page_size: 30
      end

  ### Use without macros

  If you wish to avoid use of macros or you wish to use a different name for
  the pagination function you can define your own function like so:

      defmodule MyApp.Repo do
        use Ecto.Repo, otp_app: :my_app

        def my_paginate_function(queryable, page, opts \\\\ [], repo_opts \\\\ []) do
          defaults = [page_size: 12] # Default options of your choice here
          opts = Keyword.merge(defaults, opts)
          ExToolkit.Ecto.Paginator.paginate(queryable, __MODULE__, page, opts, repo_opts)
        end
      end
  """
  import Ecto.Query, only: [exclude: 2]
  import ExToolkit.Ecto.Query, only: [apply_pagination: 3]
  import ExToolkit.Kernel, only: [validate_opts!: 2]

  @max_page_size 100
  @default_page_size 25

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

  @doc """
  Paginates an Ecto query and returns a map with pagination metadata.

  ## Arguments

  - `queryable`: The Ecto queryable (e.g., `Repo.all(User)`).
  - `repo`: The repository to execute the query.
  - `page`: The page number to fetch (starts at 1).
  - `opts`: A keyword list of options, including the `:page_size` option (default is #{@default_page_size}).
  - `repo_opts`: Ecto-specific options, see [ecto docs](https://hexdocs.pm/ecto/Ecto.Repo.html#c:all/2-options) to learn about all available options.

  ## Returns

  A map containing the following keys:
  - `:data` - The list of items for the current page.
  - `:current_page` - The current page number.
  - `:total_count` - The total number of items in the query.
  - `:total_pages` - The total number of pages based on the page size.
  - `:has_next_page` - Whether there is a next page.
  - `:has_prev_page` - Whether there is a previous page.
  - `:is_first_page` - Whether the current page is the first page.
  - `:is_last_page` - Whether the current page is the last page.
  """
  @spec paginate(Ecto.Queryable.t(), Ecto.Repo.t(), pos_integer(), options(), keyword()) :: page()
  def paginate(queryable, repo, page, opts \\ [], repo_opts \\ []) do
    %{page_size: page_size} = validate_opts!(opts, page_size: @default_page_size)
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
