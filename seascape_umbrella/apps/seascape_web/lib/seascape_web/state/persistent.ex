defmodule SeascapeWeb.State.Persistent do
  alias SeascapeWeb.Effect
  alias __MODULE__.Cluster
  defstruct [:user, :clusters]

  def new(user) do
    with {:ok, clusters} <- Seascape.Clusters.get_user_clusters(user) do
      {:ok, %__MODULE__{user: user, clusters: clusters}}
    end
  end

  def handle_event(state, {event, params}) do
    case {event, params} do
      {["cluster", "create"], %{}} ->
        create_cluster_function = fn ->
          Seascape.Clusters.create_cluster(state.user, %{name: "New cluster"})
        end

        {state, [create_cluster_function]}
      {["cluster", "created"], %{"cluster" => cluster}} ->
        state = put_in(state.clusters[cluster.id], cluster)
        {state, []}
      {["cluster", cluster_id | rest], _} ->
        Effect.update_in(state, [Access.key(:clusters), Access.key(cluster_id)], &Cluster.handle_event(&1, {rest, params}))
    end
  end
end
