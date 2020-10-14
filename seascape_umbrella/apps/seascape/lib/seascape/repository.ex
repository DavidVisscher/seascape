defmodule Seascape.Repository do
  alias Seascape.Repository.ElasticSearch
  require Logger

  defmodule ClusterDownError do
    defexception [:message]
  end

  def create(changeset, table_name) do
    try do
      with {:ok, struct} <- apply_changeset(changeset, :create),
           {:ok, _code, result} <- ElasticSearch.create(table_name, type_name(struct), pkey_value(struct), struct) do
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

  def get(primary_key_value, module, table_name) do
    try do
      ElasticSearch.get(table_name, module.__schema__(:source), primary_key_value, module)
    rescue
      ClusterDownError ->
        {:error, :cluster_down}
    end
  end

  def update(changeset, table_name) do
    try do
      with {:ok, struct} <- apply_changeset(changeset, :update),
           {:ok, _code, result} <- ElasticSearch.update(table_name, type_name(struct), pkey_value(struct), struct) do
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

  def delete(struct, table_name) do
    ElasticSearch.delete(table_name, type_name(struct), pkey_value(struct))
  end

  def search(struct_module, table_name, query) do
    ElasticSearch.search(struct_module, table_name, query)
  end

  defp pkey_value(struct = %module{}) do
    key = hd module.__schema__(:primary_key)
    get_in(struct, [Access.key(key)])
  end

  defp type_name(%module{}) do
    module.__schema__(:source)
  end

  defp apply_changeset(changeset, action) do
    with {:ok, cluster} <- Ecto.Changeset.apply_action(changeset, action) do
      res = filter_virtual_keys(cluster)
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
end
