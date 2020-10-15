defmodule SeascapeIngest.IngestChannel do
  use Phoenix.Channel

  # TODO API key auth
  def join("ingest", params, socket) do
    if authenticate_api_key(params) do
      {:ok, socket}
    else
      {:error, %{reason: "unknown API key"}}
    end
  end

  def handle_in("metrics", params, socket) do
    # Perform the handling of metrics information here.
    {:noreply, socket}
  end

  defp authenticate_api_key(params) do
    true
  end
end
