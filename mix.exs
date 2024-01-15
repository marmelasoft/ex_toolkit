defmodule ExToolkit.MixProject do
  use Mix.Project

  @app :ex_toolkit
  @name "ExToolkit"
  @version "0.8.1"
  @description "Collection of effective recipes for building Elixir applications"
  @scm_url "https://github.com/marmelasoft/ex_toolkit"

  def project do
    [
      app: @app,
      name: @name,
      description: @description,
      version: @version,
      source_url: @scm_url,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

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

  defp deps do
    [
      # databases
      {:ecto_sql, "~> 3.10"},

      # encoding
      {:uuidv7, "~> 0.2.0"},
      {:uniq, "~> 0.6.0"},
      {:base62, "~> 1.2.2"},

      # dev tools
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
