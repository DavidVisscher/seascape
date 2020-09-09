defmodule Unlucky.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: Unlucky.PubSub}
      # Start a worker by calling: Unlucky.Worker.start_link(arg)
      # {Unlucky.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Unlucky.Supervisor)
  end
end
