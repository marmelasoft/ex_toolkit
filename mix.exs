defmodule Utilx.MixProject do
  use Mix.Project

  @app :utilx
  @name "Utilx"
  @version "0.1.2"
  @description "Collection of effective recipes for building Elixir applications"
  @scm_url "https://github.com/marmelasoft/ex_utils"

  def project do
    [
      app: @app,
      name: @name,
      description: @description,
      version: @version,
      source_url: @scm_url,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      package: package(),
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

  defp deps do
    [
      {:ecto_sql, "~> 3.10"},

      # dev tools
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
