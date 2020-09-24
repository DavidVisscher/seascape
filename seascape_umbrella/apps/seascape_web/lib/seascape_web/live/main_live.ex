defmodule SeascapeWeb.MainLive do
  use Phoenix.LiveView

  def mount(_params, session, socket) do
    IO.inspect(session)
    current_user = SeascapeWeb.Credentials.get_user(socket, session, [backend: Pow.Store.Backend.MnesiaCache])
    IO.inspect(current_user)
    {:ok, clusters} = Seascape.Clusters.all_of_user(current_user)

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:clusters, clusters)
      |> assign(:page, [])
    {:ok, socket}
  end

  def handle_event(event, params, socket) do
    event
    |> String.split("/")
    |> IO.inspect(label: :event)
    |> do_handle_event(params, socket)
    |> IO.inspect(label: :handle_event)
  end

  defp do_handle_event(["clusters", "create"], _params, socket) do
    {:ok, new_cluster} = Seascape.Clusters.create(socket.assigns.current_user, %{name: "New cluster"})
    socket =
      socket
      |> assign(:clusters, [new_cluster | socket.assigns.clusters])

    {:noreply, socket}
  end

  defp do_handle_event(["clusters", "show", cluster_id], params, socket) do
    socket =
      socket
      |> assign(:page, ["clusters", "show", cluster_id])

    {:noreply, socket}
  end
end
