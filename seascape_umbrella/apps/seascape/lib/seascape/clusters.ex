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

  def create(params) do
    Cluster.new()
    |> Cluster.changeset(params)
    |> Repository.create(@table_name)
  end

  def delete(cluster) do
    Repository.delete(cluster, @table_name)
  end

  def update(cluster, params) do
    cluster
    |> Cluster.changeset(params)
    |> Repository.update(cluster, @table_name)
  end
end