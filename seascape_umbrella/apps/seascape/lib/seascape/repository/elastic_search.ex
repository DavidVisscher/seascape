defmodule Seascape.Repository.ElasticSearch do
  @moduledoc """
  Wrapper around the `Elastic` library
  that performs a health-check and slightly abstracts away
  some low-level details of ElasticSearch.
  """
  use CapturePipe

  def raise_unless_cluster_ok!() do
    unless __MODULE__.Watchdog.cluster_ok?() do
      raise Seascape.Repository.ClusterDownError, "ElasticSearch database cannot be reached."
    end
  end

  def create(index, type, key, data) do
    raise_unless_cluster_ok!()
    Elastic.Document.index(index, type, key, data)
  end

  def get(index, type, key, struct_module) do
    raise_unless_cluster_ok!()
    case Elastic.Document.get(index, type, key) do
      {:ok, _code, %{"_source" => source}} ->
        {:ok, into_struct(struct_module, source)}
      {:error, 404, %{"found" => false}} ->
        {:error, :not_found}
    end
  end

  defp into_struct(struct_module, source) do
    source
    |> Enum.into(%{}, fn {key, val} -> {String.to_existing_atom(key), val} end)
    |> &struct(struct_module, &1)
  end

  def update(index, type, key, data) do
    raise_unless_cluster_ok!()
    Elastic.Document.update(index, type, key, data)
  end

  def delete(index, type, key) do
    raise_unless_cluster_ok!()

    require Logger
    Logger.debug(inspect({index, type, key}))
    case Elastic.Document.delete(index, type, key) do
      {:ok, _code, _result} ->
        :ok
      {:error, 404, _} ->
        {:error, :not_found}
      {:error, code, problem} ->
        {:error, code, problem}
    end
  end

  def search(struct_module, index, query) do
    result =
      Elastic.Query.build(index, query)
      |> Elastic.Index.search()
    case result do
      {:error, _code, problem} ->
        {:error, problem}
      {:ok, 200, %{"hits" => %{"hits" => hits}}} ->
        hits
        |> Enum.map(fn %{"_source" => source, "_id" => _id} ->
          into_struct(struct_module, source)
        end)
        |> &{:ok, &1}
    end
  end
end
