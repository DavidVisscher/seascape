defmodule Seascape.Repository do
  alias Seascape.Repository.ElasticSearch
  alias Seascape.Repository.ElasticSearch.Watchdog
  require Logger

  defmodule ClusterDownError do
    defexception [:message]
  end

  def cluster_ok? do
    Watchdog.cluster_ok?()
  end

  def subscribe_to_cluster_status do
    Phoenix.PubSub.subscribe(Seascape.PubSub, "Seascape.Repository/health")
  end

  def create(changeset) do
    try do
      with {:ok, struct} <- apply_changeset(changeset, :create),
           {:ok, _code, result} <- ElasticSearch.create(table_name(struct), type_name(struct), pkey_value(struct), struct) do
        Logger.debug(inspect(result))
        {:ok, struct}
      else
        {:error, problem} ->
          {:error, problem}
        {:error, code, problem} ->
          changeset =
          Ecto.Changeset.add_error(changeset, pkey_value(changeset.data), inspect(problem["error"]), http_status_code: code)
        {:error, changeset}
      end
    rescue
      ClusterDownError ->
        changeset =
          Ecto.Changeset.add_error(changeset, pkey_value(changeset.data), "Data persistence is currently not possible.")
        {:error, changeset}
    end
  end

  def bulk_create(list_of_changesets) do
    list_of_changesets
    |> Enum.map(&apply_changeset!(&1, :create))
    |> Enum.map(fn struct ->
      {table_name(struct), type_name(struct), pkey_value(struct), struct}
    end)
    |> ElasticSearch.bulk_create
  end

  def get(primary_key_value, module) do
    try do
      ElasticSearch.get(table_name(module), type_name(module), primary_key_value, module)
    rescue
      ClusterDownError ->
        {:error, :cluster_down}
    end
  end

  def update(changeset) do
    try do
      with {:ok, struct} <- apply_changeset(changeset, :update),
           {:ok, _code, result} <- ElasticSearch.update(table_name(struct), type_name(struct), pkey_value(struct), struct) do
        Logger.debug(inspect(result))
        {:ok, struct}
      else
        {:error, problem} ->
          {:error, problem}
        {:error, code, problem} ->
          changeset =
          Ecto.Changeset.add_error(changeset, pkey_value(changeset.data), problem["error"], http_status_code: code)
        {:error, changeset}
      end
    rescue
      ClusterDownError ->
        changeset =
        Ecto.Changeset.add_error(changeset, pkey_value(changeset.data), "Data persistence is currently not possible.")
      {:error, changeset}
    end
  end

  def delete(struct) do
    ElasticSearch.delete(table_name(struct), type_name(struct), pkey_value(struct))
  end

  def delete_all(struct_module) do
    Elastic.HTTP.delete(Elastic.Index.name(table_name(struct_module)) <> "/_query", body: %{"query" => %{"match_all" => %{}}})
  end

  def search(struct_module, query, opts \\ [extract_hits: true]) do
    ElasticSearch.search(struct_module, table_name(struct_module), query, opts)
  end

  defp pkey_value(struct = %module{}) do
    if function_exported?(module, :primary_key, 1) do
      module.primary_key(struct)
    else
      key = hd module.__schema__(:primary_key)
      get_in(struct, [Access.key(key)])
    end
  end

  defp type_name(%module{}), do: type_name(module)
  defp type_name(module) when is_atom(module), do: "_doc"

  defp table_name(%module{}), do: table_name(module)
  defp table_name(module) when is_atom(module), do: module.__schema__(:source)

  defp apply_changeset!(changeset, action) do
    {:ok, struct} = apply_changeset(changeset, action)
    struct
  end

  defp apply_changeset(changeset, action) do
    with {:ok, data} <- Ecto.Changeset.apply_action(changeset, action) do
      res = filter_virtual_keys(data)
      {:ok, res}
    end
  end

  # Since we are not using an Ecto adapter
  # we need to do this ourselves.
  defp filter_virtual_keys(%module{} = struct) do
    Enum.reduce(struct |> Map.from_struct |> Map.keys, struct, fn key, struct ->
      if key not in module.__schema__(:fields) do
        put_in(struct, [Access.key(key)], nil)
      else
        struct
      end
    end)
  end

  def refresh_all do
    ElasticSearch.refresh_all
  end

  def refresh(struct_module) do
    ElasticSearch.refresh(table_name(struct_module))
  end

end
