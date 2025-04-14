defmodule ExToolkit.TestRepo do
  use Ecto.Repo,
    otp_app: :ex_toolkit,
    adapter: Ecto.Adapters.SQLite3

  use ExToolkit.Ecto.Paginator
end
