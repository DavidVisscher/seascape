defmodule SeascapeWeb.State.Persistent.Cluster do
  defstruct [:name, :id, :api_key, :metrics]

  def new({cluster_id, cluster}) do
    with {:ok, metrics} <- Seascape.Clusters.get_metrics(cluster_id) do
      {:ok, {cluster_id, %__MODULE__{name: cluster.name, id: cluster.id, api_key: cluster.api_key, metrics: invert_cluster_metrics(metrics)}}}
      # {:ok, %{cluster | metrics: metrics}}
    end
  end

  def handle_event(state, {event, params}) do
    # For now do nothing
    case {event, params} do
      _ ->
        {state, []}
    end
  end

  def invert_cluster_metrics(metrics) do
    metrics
    |> Enum.group_by(&(&1.hostname))
    |> Enum.map(&invert_machine_metrics/1)
    |> Enum.into(%{})
  end

  defp invert_machine_metrics({hostname, machine_metrics}) do
    {hostname, Enum.group_by(machine_metrics, &(&1.container_ref))}
    |> IO.inspect(label: :result)
  end
end
