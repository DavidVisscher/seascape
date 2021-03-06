defmodule SeascapeWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :seascape_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SeascapeWeb.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :mnesia]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Remote dependencies:
      {:phoenix, "~> 1.5.4"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix_live_view, "~> 0.14.6"},
      {:pow, "~> 1.0.20"},
      {:libcluster, "~> 3.2.1"},
      {:ring_logger, "~> 0.6"},
      {:solution, "~> 1.0"},
      {:faker, "~> 0.16"},

      # Testing only/dev only:
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:floki, ">= 0.27.0", only: :test},

      # In umbrella:
      {:seascape, in_umbrella: true}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"]
    ]
  end
end
