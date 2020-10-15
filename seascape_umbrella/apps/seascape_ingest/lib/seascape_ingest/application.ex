defmodule SeascapeIngest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    endpoint_config = Application.get_env(:seascape_ingest, SeascapeIngest.Endpoint, [])
    children = [
      # Starts a worker by calling: SeascapeIngest.Worker.start_link(arg)
      # {SeascapeIngest.Worker, arg}
      {Plug.Cowboy, ([plug: SeascapeIngest.Endpoint] ++ endpoint_config)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SeascapeIngest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
