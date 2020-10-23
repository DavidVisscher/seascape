defmodule SeascapeIngest.IngestChannel do
  use Phoenix.Channel
  use CapturePipe
  import Solution

  def join("ingest", params, socket) do
    scase authenticate_api_key(params) do
      ok(cluster_id) ->
        socket
        |> assign(:cluster_id, cluster_id)
        |> &{:ok, &1}
      error() ->
        {:error, %{reason: "unknown API key"}}
    end
  end

  def handle_in("metrics", payload, socket) do
    payload
    |> WaveParser.parse()
    |> Enum.map(&store_metric!(socket.assigns.cluster_id, &1))

    {:noreply, socket}
  end

  defp authenticate_api_key(params) do
    Seascape.Clusters.get_cluster_by_api_key(params["api_key"])
  end

  defp store_metric!(cluster_id, %{key: key, value: value, container_ref: container_ref, vm_hostname: vm_hostname}) do
    Seascape.Clusters.store_container_metric!(cluster_id, %{key: key, value: value, container_ref: container_ref, hostname: vm_hostname})
  end

  defp store_metric!(cluster_id, %{key: key, value: value, vm_hostname: vm_hostname}) do
    Seascape.Clusters.store_machine_metric!(cluster_id, %{key: key, value: value, hostname: vm_hostname})
  end
end
