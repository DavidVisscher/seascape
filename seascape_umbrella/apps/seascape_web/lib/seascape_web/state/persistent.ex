defmodule SeascapeWeb.State.Persistent do
  defstruct [:user, :clusters]

  def new(user) do
    with {:ok, clusters} <- Seascape.Clusters.all_of_user(user) do
      {:ok, %__MODULE__{user: user, clusters: clusters}}
    end
  end

  def handle_event(state, {event, params}) do
    case {event, params} do
      {["cluster", "create"], %{}} ->
        create_cluster_function = fn ->
          Seascape.Clusters.create(state.user, %{name: "New cluster"})
        end

        {state, [create_cluster_function]}
      {["cluster", "created"], %{"cluster" => cluster}} ->
        state = put_in(state.clusters[cluster.id], cluster)
        {state, []}
      ["cluster", cluster_id | rest] ->
        Effect.update_in(state, [Access.key(:clusters), Access.key(cluster_id)], &Clusters.handle_event(&1, {rest, params}))
    end
  end
end
