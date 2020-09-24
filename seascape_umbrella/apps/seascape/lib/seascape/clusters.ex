defmodule Seascape.Clusters do
  alias __MODULE__.Cluster
  use CapturePipe
  alias Seascape.ElasticSearch

  @moduledoc """
  The `Clusters` DDD-context. Responsible for reading/writing cluster information/configuration.
  """

  defp index_name() do
    "clusters"
  end

  defp type_name() do
    "seascape_cluster"
  end

  def get(id) do
    ElasticSearch.get(index_name(), type_name(), id, Cluster)
  end

  def create(params) do
    Cluster.new()
    |> Cluster.changeset(params)
    |> do_create()
  end

  defp do_create(changeset) do
    case apply_changeset(changeset, :create) do
      {:error, problem} ->
        {:error, problem}
      {:ok, cluster} ->
        ElasticSearch.create(index_name(), type_name(), cluster.id, cluster)
        {:ok, cluster}
    end
  end

  def delete(cluster) do
    ElasticSearch.delete(index_name(), type_name(), cluster.id)
  end

  def update(cluster, params) do
    cluster
    |> Cluster.changeset(params)
    |> do_update()
  end

  defp do_update(cluster) do
    case apply_changeset(cluster, :update) do
      {:error, problem} ->
        {:error, problem}
      {:ok, cluster} ->
        ElasticSearch.update(index_name(), type_name(), cluster.id, cluster)
        {:ok, cluster}
    end
  end

  defp apply_changeset(changeset, action) do
    with {:ok, cluster} <- Ecto.Changeset.apply_action(changeset, action) do
      res = filter_virtual_keys(cluster)
      {:ok, res}
    end
  end

  # Since we are not using an Ecto adapter
  # we need to do this ourselves.
  defp filter_virtual_keys(cluster) do
    Enum.reduce(cluster |> Map.from_struct |> Map.keys, cluster, fn key, cluster ->
      if key not in Cluster.__schema__(:fields) do
        put_in(cluster, [Access.key(key)], nil)
      else
        cluster
      end
    end)
  end
end
