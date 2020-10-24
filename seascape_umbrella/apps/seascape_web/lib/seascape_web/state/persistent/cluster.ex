defmodule SeascapeWeb.State.Persistent.Cluster do
  defstruct [:name, :id, :api_key, :metrics]

  def new({cluster_id, cluster}) do
    with {:ok, metrics} <- Seascape.Clusters.get_metrics(cluster_id) do
      {:ok, {cluster_id, %__MODULE__{name: cluster.name, id: cluster.id, api_key: cluster.api_key, metrics: metrics}}}
      # {:ok, %{cluster | metrics: metrics}}
      |> IO.inspect(label: :cluster_new)
    end
  end

  def handle_event(state, {event, params}) do
    # For now do nothing
    case {event, params} do
      _ ->
        {state, []}
    end
  end
end
