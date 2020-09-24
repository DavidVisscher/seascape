defmodule Seascape.Repository do
  def create(changeset, table_name) do
    case apply_changeset(changeset, :create) do
      {:error, problem} ->
        {:error, problem}
      {:ok, struct} ->
        ElasticSearch.create(table_name, type_name(struct), pkey_value(struct), struct)
        {:ok, user}
    end
  end

  def get(primary_key_value, module, table_name) do
    ElasticSearch.get(table_name, type_name(%module{}), primary_key_value, module)
  end

  def update(changeset, table_name) do
    case apply_changeset(changeset, :update) do
      {:error, problem} ->
        {:error, problem}
      {:ok, struct} ->
        res = ElasticSearch.update(table_name, type_name(struct), pkey_value(struct), struct)
        {:ok, res}
    end
  end

  def delete(struct, table_name) do
    ElasticSearch.delete(table_name, type_name(struct), pkey_value(struct))
  end

  defp pkey_value(struct = %module{}) do
    key = module.__schema__(:primary_key)
    get_in(struct, Access.key(key))
  end

  defp type_name(struct = %module{}) do
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
