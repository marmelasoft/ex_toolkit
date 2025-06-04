defmodule ExToolkit.MixProject do
  use Mix.Project

  @app :ex_toolkit
  @name "ExToolkit"
  @version "0.12.4"
  @description "Collection of effective recipes for building Elixir applications"
  @scm_url "https://github.com/marmelasoft/ex_toolkit"

  def project do
    [
      app: @app,
      name: @name,
      description: @description,
      version: @version,
      source_url: @scm_url,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      dialyzer: dialyzer(),
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [check: :test]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @scm_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix],
      plt_file:
        {:no_warn, ".dialyzer/elixir-#{System.version()}-erlang-otp-#{System.otp_release()}.plt"}
    ]
  end

  defp deps do
    [
      # databases
      {:ecto_sql, "~> 3.10", optional: true},
      {:ecto_sqlite3, "~> 0.13.0", only: :test},

      # encoding
      {:uuidv7, "~> 1.0.0"},
      {:uniq, "~> 0.6.0"},
      {:base62, "~> 1.2.2"},

      # dev tools
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      "lint.credo": ["credo --strict --all"],
      "lint.dialyzer": ["dialyzer --format dialyxir --quiet"],
      "lint.sobelow": ["sobelow --threshold high"],
      lint: ["lint.dialyzer", "lint.credo", "lint.sobelow"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      check: [
        "hex.audit",
        "clean",
        "deps.unlock --check-unused",
        "compile --all-warnings --warnings-as-errors",
        "format --check-formatted",
        "deps.unlock --check-unused",
        "test --warnings-as-errors",
        "lint.credo",
        "lint.sobelow"
      ]
    ]
  end
end
