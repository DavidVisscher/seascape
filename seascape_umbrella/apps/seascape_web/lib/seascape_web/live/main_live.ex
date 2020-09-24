defmodule SeascapeWeb.MainLive do
  use Phoenix.LiveView
  use CapturePipe

  alias SeascapeWeb.State

  def mount(_params, session, socket) do
    IO.inspect(session)
    current_user = SeascapeWeb.Credentials.get_user(socket, session, [backend: Pow.Store.Backend.MnesiaCache])
    with {:ok, state} <- State.new(current_user) do
      socket
      |> assign(:state, state)
      |> &{:ok, &1}
    end
  end

  def handle_event(event, params, socket) do
    event
    |> String.split("/")
    |> IO.inspect(label: :event)
    |> do_handle_event(params, socket)
    |> IO.inspect(label: :handle_event)
  end

  defp do_handle_event(event, params, socket) do
    {new_state, _effects} =
      socket.assigns.state
      |> SeascapeWeb.State.handle_event({event, params})

    socket
    |> assign(:state, new_state)
    |> &{:noreply, &1}
  end

  # defp do_handle_event(["clusters", "create"], _params, socket) do
  #   {:ok, new_cluster} = Seascape.Clusters.create(socket.assigns.current_user, %{name: "New cluster"})
  #   socket
  #   |> assign(:clusters, [new_cluster | socket.assigns.clusters])
  #   |> &{:noreply, &1}
  # end

  # defp do_handle_event(["clusters", "show", cluster_id], params, socket) do
  #   socket
  #   |> assign(:page, ["clusters", "show", cluster_id])
  #   |> &{:noreply, &1}
  # end
end
