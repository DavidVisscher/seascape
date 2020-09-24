defmodule Seascape.Repository do
  alias Seascape.Repository.ElasticSearch

  defmodule ClusterDownError do
    defexception [:message]
  end

  def create(changeset, table_name) do
    with {:ok, struct} <- apply_changeset(changeset, :create),
         {:ok, 200, result} <- ElasticSearch.create(table_name, type_name(struct), pkey_value(struct), struct) do
      {:ok, result}
    end
  end

  def get(primary_key_value, module, table_name) do
    ElasticSearch.get(table_name, module.__schema__(:source), primary_key_value, module)
  end

  def update(changeset, table_name) do
    with {:ok, struct} <- apply_changeset(changeset, :update),
         {:ok, 200, result} <- ElasticSearch.update(table_name, type_name(struct), pkey_value(struct), struct) do
      {:ok, result}
      end
  end

  def delete(struct, table_name) do
    ElasticSearch.delete(table_name, type_name(struct), pkey_value(struct))
  end

  defp pkey_value(struct = %module{}) do
    key = module.__schema__(:primary_key)
    get_in(struct, [Access.key(key)])
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
