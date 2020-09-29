defmodule SeascapeWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SeascapeWeb.Telemetry,
      # Start the Endpoint (http/https)
      SeascapeWeb.Endpoint,
      Pow.Store.Backend.MnesiaCache
      # Start a worker by calling: SeascapeWeb.Worker.start_link(arg)
      # {SeascapeWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SeascapeWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SeascapeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
