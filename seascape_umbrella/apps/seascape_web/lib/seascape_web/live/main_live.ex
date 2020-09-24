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
    {:ok, socket}
  end
end
