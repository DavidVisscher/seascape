defmodule SeascapeIngest.IngestChannel do
  use Phoenix.Channel
  use CapturePipe
  import Solution

  alias SeascapeIngest.WaveParser

  def join("ingest", params, socket) do
    scase authenticate_api_key(params) do
      ok(cluster) ->
        socket
        |> assign(:cluster_id, cluster.id)
        |> &{:ok, &1}
      error() ->
        {:error, %{reason: "unknown API key"}}
    end
  end

  def handle_in("metrics", payload, socket) do
    payload
    |> WaveParser.parse()
    # |> Enum.map(&store_metric!(socket.assigns.cluster_id, &1))
    |> store_container_metrics!(socket.assigns.cluster_id)

    {:reply, :ok, socket}
  end

  defp authenticate_api_key(params) do
    Seascape.Clusters.get_cluster_by_api_key(params["api_key"])
  end

  defp store_metric!(cluster_id, %{key: key, value: value, timestamp: timestamp, vm_hostname: vm_hostname, container_ref: container_ref}) do
    Seascape.Clusters.store_container_metric!(cluster_id, %{key: key, value: value, timestamp: timestamp, container_ref: container_ref, hostname: vm_hostname})
  end

  defp store_metric!(cluster_id, %{key: key, value: value, timestamp: timestamp, vm_hostname: vm_hostname}) do
    Seascape.Clusters.store_machine_metric!(cluster_id, %{key: key, value: value, timestamp: timestamp, hostname: vm_hostname})
  end

  defp store_container_metrics!(metrics, cluster_id) do
    metrics
    |> Enum.filter(&(&1[:container_ref]))
    |> Enum.map(fn %{key: key, value: value, timestamp: timestamp, vm_hostname: vm_hostname, container_ref: container_ref} ->
      %{key: key, value: value, timestamp: timestamp, hostname: vm_hostname, container_ref: container_ref}
    end)
    |> Seascape.Clusters.store_container_metrics!(cluster_id)
  end
end
