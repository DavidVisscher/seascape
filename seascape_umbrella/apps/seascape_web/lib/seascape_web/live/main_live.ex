defmodule SeascapeWeb.MainLive do
  use Phoenix.LiveView, layout: {SeascapeWeb.LayoutView, "live.html"}
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
        |> assign(:seconds, [])
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
  def handle_params(params = %{"spa_path" => path}, url, socket) do
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
      |> assign(:seconds, [{DateTime.utc_now(), Time.utc_now |> Time.to_erl |> elem(2)} | socket.assigns.seconds])
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

  def line_chart(id, label, points, assigns) do
    type = "line"
    data = %{
      datasets: [%{
                    label: label,
                    data: points
                 }]
    }
    options = %{scales: %{ xAxes: [%{type: "time"}]}}
    %{type: type, data: data, options: options}
    ~L"""
    <div
      id="<%= id %>"
      phx-update="ignore"
      phx-hook="Chart"
      data-chart-type="<%= type %>"
      data-chart-data="<%= Jason.encode!(data) %>"
      data-chart-options="<%= Jason.encode!(options) %>"
    >
    </div>
    """
  end
end
