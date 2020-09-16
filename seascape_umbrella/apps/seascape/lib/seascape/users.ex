defmodule Seascape.Users do
  alias __MODULE__.User
  use CapturePipe

  @moduledoc """
  The `Users` context. Responsible for user registration/autorization.

  This particular module's functions can be used
  to read/write users in the database.

  - The actual datatype and (persistence-less) logic is found in `Seascape.Users.User`.
  - Authentication can be done using `Seascape.Users.PowContext` (and this is usually handled inside the Pow HTTP Plug).
  """

  defp index_name() do
    "user"
  end

  defp type_name() do
    "seascape_user"
  end

  def get(email) do
    case Elastic.Document.get(index_name(), type_name(), email) do
      {:ok, 200, %{"_source" => source}} ->
        {:ok, into_struct(source)}
      {:error, 404, %{"found" => false}} ->
        {:error, :not_found}
    end
  end

  defp into_struct(source) do
    source
    |> Enum.into(%{}, fn {key, val} -> {String.to_existing_atom(key), val} end)
    |> &struct(User, &1)
  end

  def create(params) do
    User.new()
    |> User.changeset(params)
    |> Ecto.Changeset.validate_change(User.pow_user_id_field, &validates_uniqueness/2)
    |> do_create()
  end

  defp validates_uniqueness(key, value) do
    case get(value) do
      {:ok, _user} ->
        [{key,  "already taken"}]
      {:error, :not_found} ->
        []
    end
  end

  def do_create(changeset) do
    case apply_changeset(changeset, :create) do
      {:error, problem} ->
        {:error, problem}
      {:ok, user} ->
        Elastic.Document.index(index_name(), type_name(), user.email, user)
        {:ok, user}
    end
  end

  def delete(user) do
    Elastic.Document.delete(index_name(), type_name(), user.email)
  end

  def update(user, params) do
    user
    |> User.changeset(params)
    |> apply_changeset(:update)
    |> do_update()
  end

  defp do_update(user) do
    Elastic.Document.update(index_name(), type_name(), user.email, user)
  end

  defp apply_changeset(changeset, action) do
    with {:ok, user} <- Ecto.Changeset.apply_action(changeset, action) do
      res = filter_virtual_keys(user)
      {:ok, res}
    end
  end

  # Since we are not using an Ecto adapter
  # we need to do this ourselves.
  defp filter_virtual_keys(user) do
    Enum.reduce(user |> Map.from_struct |> Map.keys, user, fn key, user ->
      if key not in User.__schema__(:fields) do
        put_in(user, [Access.key(key)], nil)
      else
        user
      end
    end)
  end
end
