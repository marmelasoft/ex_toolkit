import Config

if config_env() == :test do
  config :ex_toolkit, ecto_repos: [ExToolkit.TestRepo]

  config :ex_toolkit, ExToolkit.TestRepo,
    log: false,
    database: Path.expand("../priv/test_repo/databases/test.sqlite3", __DIR__),
    pool: Ecto.Adapters.SQL.Sandbox,
    pool_size: 5
end
