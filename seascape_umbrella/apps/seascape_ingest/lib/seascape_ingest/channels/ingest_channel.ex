defmodule SeascapeIngest.IngestChannel do
  use Phoenix.Channel

  # TODO API key auth
  def join("ingest", payload, socket) do
    if authenticate_api_key(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unknown API key"}}
    end
  end

  def handle_in("metrics", payload, socket) do
    # Perform the handling of metrics information here.
    WaveParser.parse(payload)
    |> Enum.map(fn metric ->
      Seascape.Clusters.store_metric!(socket.assigns.cluster_id, metric)
    end)
    {:noreply, socket}
  end

  defp authenticate_api_key(_params) do
    true
  end
end
