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
    |> store_container_metrics!(socket.assigns.cluster_id)

    {:reply, :ok, socket}
  end

  defp authenticate_api_key(params) do
    Seascape.Clusters.get_cluster_by_api_key(params["api_key"])
  end

  defp store_container_metrics!(metrics, cluster_id) do
    metrics
    |> Enum.filter(&(&1[:container_ref]))
    |> Enum.map(fn data = %{timestamp: timestamp, vm_hostname: vm_hostname, container_ref: container_ref} ->
      clean_data =
        data
        |> Map.delete(:timestamp)
        |> Map.delete(:vm_hostname)
        |> Map.delete(:container_ref)

      %{timestamp: timestamp, hostname: vm_hostname, container_ref: container_ref, data: clean_data}
    end)
    |> Seascape.Clusters.store_container_metrics!(cluster_id)
  end
end
