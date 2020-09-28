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
    Cluster.new(user.id)
    |> Cluster.changeset(params)
    |> Repository.create(@table_name)
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
    Repository.search(Cluster, @table_name,
      %{query: %{
           constant_score: %{
             filter: %{
               term: %{
                 user_id: user.id
               }
             }
           }
        }
      }
    )
  end
end
