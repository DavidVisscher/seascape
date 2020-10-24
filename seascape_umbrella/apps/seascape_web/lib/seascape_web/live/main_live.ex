defmodule SeascapeWeb.MainLive do
  use SeascapeWeb, :live_view
  use CapturePipe

  alias SeascapeWeb.State

  def mount(_params, session, socket) do
    IO.inspect(session)
    case SeascapeWeb.Credentials.get_user(socket, session, [backend: Pow.Store.Backend.MnesiaCache]) do

      nil ->
        Process.send_after(self, :update_self, 1000)
        {:ok, state} = State.new()

        socket
        |> assign(:current_user, nil)
        |> assign(:state, state)
        |> &{:ok, &1}

      current_user ->
        Seascape.Clusters.subscribe(current_user)

        with {:ok, state} <- State.new(current_user) do
          socket
          |> assign(:current_user, current_user)
          |> assign(:state, state)
          |> &{:ok, &1}
        else
          {:error, _} ->
            {:ok, state} = State.new()
            socket
            |> assign(:current_user, current_user)
            |> assign(:state, state)
            |> &{:ok, &1}
        end
    end
  end

  # Invoked on page change.
  def handle_params(params = %{"spa_path" => _}, _url, socket) do
    do_handle_event(["ephemeral", "changed_page"], params, socket)
  end

  def handle_event(event, params, socket) do
    IO.inspect({event, params}, label: :handle_info)

    event
    |> String.split("/")
    |> do_handle_event(params, socket)
    |> IO.inspect(label: :handle_event_result)
  end

  def handle_info(:update_self, socket) do
    IO.puts("Updated!")

    Process.send_after(self, :update_self, 1000)
    socket =
      socket
    {:noreply, socket}
  end

  def handle_info({event, params}, socket) do
    IO.inspect({event, params}, label: :handle_info)

    event
    |> String.split("/")
    |> do_handle_event(params, socket)
    |> IO.inspect(label: :handle_info_result)
  end

  defp do_handle_event(event, params, socket) do
    {new_state, effects} =
      socket.assigns.state
      |> SeascapeWeb.State.handle_event({event, params})

    socket
    |> SeascapeWeb.EffectInterpreter.execute_effects(effects)
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

  require Integer

  def breadcrumbs(current_page, socket) do
    assigns = socket.assigns
    ~L"""
    <%= for element <- (current_page |> Enum.scan([], &[&1 | &2])) do %>
    <div class="divider">/</div>
      <%= case element do %>
        <% list when Integer.is_odd(length(list)) -> %>
          <span><%= hd(list) %></span>
        <% list -> %>
        <%= live_patch (hd(list)), to: Routes.live_path(socket, SeascapeWeb.MainLive, (Enum.reverse(list))), class: "section" %>
      <% end %>
    <% end %>
    """
  end

end
