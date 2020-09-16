defmodule Seascape.Users do
  @moduledoc """
  The `Users` context. Responsible for user registration/autorization.

  This particular module's functions can be used
  to read/write users in the database.

  - The actual datatype and (persistence-less) logic is found in `Seascape.Users.User`.
  - Authentication can be done using `Seascape.Users.PowContext` (and this is usually handled inside the Pow HTTP Plug).
  """
  alias __MODULE__.User

  def get(email) do
    case User.get(email) do
      user = %User{} -> {:ok, user}
      nil -> {:error, :not_found}
    end
  end

  def create(params) do
    User.new()
    |> User.changeset(params)
    |> Ecto.Changeset.validate_change(User.pow_user_id_field , &validates_uniqueness/2)
    |> do_create()
  end

  defp validates_uniqueness(key, value) do
    case User.get(value) do
      %User{} ->
        [{key,  "already taken"}]
      nil ->
        []
    end
  end

  def do_create(changeset) do
    case apply_changeset(changeset, :create) do
      {:error, problem} ->
        {:error, problem}
      {:ok, user} ->
        Seascape.Users.User.index(user.email , user)
        {:ok, user}
    end
  end

  def delete(user) do
    Seascape.Users.User.delete(user.email)
  end

  def update(user, params) do
    user
    |> User.changeset(params)
    |> apply_changeset(:update)
    |> do_update()
  end

  defp do_update(user) do
    User.index(user.email, user)
  end

  defp apply_changeset(changeset, action) do
    with {:ok, user} <- Ecto.Changeset.apply_action(changeset, action) do
      res = filter_virtual_keys(user)
      {:ok, res}
    end
  end

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
