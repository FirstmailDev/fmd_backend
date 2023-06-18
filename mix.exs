defmodule Firstmail.MixProject do
  use Mix.Project

  def project do
    [
      app: :firstmail,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Firstmail.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:gun, "~> 2.0", only: :test},
      {:cowboy, "~> 2.10"},
      {:ecto_ulid_next, "~> 1.0"},
      {:ecto_sqlite3, "~> 0.10.3"},
      {:certifi, "~> 2.11"},
      {:gen_smtp, "~> 1.2"},
      {:iconv, "~> 1.0"}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
