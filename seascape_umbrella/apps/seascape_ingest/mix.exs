defmodule SeascapeIngest.MixProject do
  use Mix.Project

  def project do
    [
      app: :seascape_ingest,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SeascapeIngest.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Remote dependencies:
      {:plug, "~> 1.10"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:solution, "~> 1.0"},

      # In umbrella:
      {:seascape, in_umbrella: true}
    ]
  end
end