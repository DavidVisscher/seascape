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
      {["metrics"], new_metrics} ->
        IO.inspect("Received new metrics: #{inspect(new_metrics)}")
        new_metrics = invert_cluster_metrics(new_metrics)
        {merge_metrics(state, new_metrics), []}
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

  def merge_metrics(cluster_with_metrics, new_metrics) do
    old_metrics = cluster_with_metrics.metrics
    Enum.reduce(new_metrics, old_metrics, fn {hostname, new_machine_metrics}, new_metrics ->
      old_metrics
      |> Map.update(hostname, new_machine_metrics, &merge_machine_metrics/2)
    end)
  end

  def merge_machine_metrics(old_machine_metrics, new_machine_metrics) do
    Enum.reduce(new_machine_metrics, old_machine_metrics, fn {container_ref, new_container_metrics}, new_machine_metrics ->
      old_machine_metrics
      |> Map.update(container_ref, new_container_metrics, fn old, new -> (new ++ old) end)
    end)
  end
end
