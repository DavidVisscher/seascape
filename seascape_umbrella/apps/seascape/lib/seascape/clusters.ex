defmodule Seascape.Clusters do
  alias __MODULE__.Cluster
  use CapturePipe
  alias Seascape.Repository

  @moduledoc """
  The `Clusters` DDD-context. Responsible for reading/writing cluster information/configuration.
  """

  @table_name "clusters"

  def get(id) do
    Repository.get(id, Cluster, @table_name)
  end

  def create(user, params) do
    result =
      Cluster.new(user.id)
      |> Cluster.changeset(params)
      |> Repository.create(@table_name)
    case result do
      {:ok, result} ->
        Phoenix.PubSub.broadcast(Seascape.PubSub, "#{__MODULE__}:#{user.id}:clusters", {"persistent/cluster/created", %{"cluster" => result}})
        {:ok, result}
      other ->
        other
    end
  end

  def delete(cluster) do
    Repository.delete(cluster, @table_name)
  end

  def update(cluster, params) do
    cluster
    |> Cluster.changeset(params)
    |> Repository.update(@table_name)
  end

  def all_of_user(user) do
    case Repository.search(Cluster, @table_name,
      %{query: %{
           match: %{
             user_id: user.id
           }
        }
      }
        ) do
      {:ok, results} ->
        results
        |> Enum.map(fn cluster -> {cluster.id, cluster} end)
        |> Enum.into(%{})
        |> &{:ok, &1}
      other ->
        other
    end
  end

  @doc """
  When subscribed, process will be kept up-to-date
  of changes happening to all clusters of `user`.
  """
  def subscribe(user) do
    Phoenix.PubSub.subscribe(Seascape.PubSub, "#{__MODULE__}:#{user.id}:clusters")
  end
end
