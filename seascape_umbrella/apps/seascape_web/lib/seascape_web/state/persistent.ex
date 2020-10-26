defmodule SeascapeWeb.State.Persistent do
  alias SeascapeWeb.Effect
  alias __MODULE__.Cluster
  defstruct [:user, :clusters]
  import Solution

  def new(user) do
    swith ok(raw_clusters) <- Seascape.Clusters.get_user_clusters(user),
          ok(filled_clusters) <- raw_clusters |> Enum.map(&Cluster.new/1) |> Solution.Enum.combine() do
      {:ok, %__MODULE__{user: user, clusters: Enum.into(filled_clusters, %{})}}
    end
  end

  def handle_event(state, {event, params}) do
    case {event, params} do
      {["cluster", "create"], %{}} ->
        create_cluster_function = fn ->
          Seascape.Clusters.create_cluster(state.user, %{name: "#{Faker.Superhero.prefix()} #{Faker.Food.En.spice()}"})
        end

        {state, [create_cluster_function]}
      {["cluster", "created"], %{"cluster" => cluster}} ->
        {:ok, {_, filled_cluster}} = Cluster.new({cluster.id, cluster})
        state = put_in(state.clusters[cluster.id], filled_cluster)
        {state, []}
      {["cluster", cluster_id | rest], _} ->
        Effect.update_in(state, [Access.key(:clusters), Access.key(cluster_id)], &Cluster.handle_event(&1, {rest, params}))
    end
  end
end
