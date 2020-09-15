defmodule Seascape.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: Seascape.PubSub}
      # Start a worker by calling: Seascape.Worker.start_link(arg)
      # {Seascape.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Seascape.Supervisor)
  end
end
