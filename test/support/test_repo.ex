defmodule ExToolkit.TestRepo do
  @moduledoc "Ecto repository for testing purposes."
  use Ecto.Repo,
    otp_app: :ex_toolkit,
    adapter: Ecto.Adapters.SQLite3

  use ExToolkit.Ecto.Paginator
end
