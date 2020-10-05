defmodule Seascape.Users do
  alias __MODULE__.User
  use CapturePipe
  alias Seascape.Repository

  @moduledoc """
  The `Users` DDD-context. Responsible for user registration/autorization.

  This particular module's functions can be used
  to read/write users in the database.

  - The actual datatype and (persistence-less) logic is found in `Seascape.Users.User`.
  - Authentication can be done using `Seascape.Users.PowContext` (and this is usually handled inside the Pow HTTP Plug).
  """

  @table_name "users"

  def get(email) do
    Repository.get(email, User, @table_name)
  end

  def create(params) do
    User.new()
    |> User.changeset(params)
    |> Ecto.Changeset.validate_change(User.pow_user_id_field, &validates_uniqueness/2)
    |> Repository.create(@table_name)
  end

  def delete(user) do
    Repository.delete(user, @table_name)
  end

  def update(user, params) do
    user
    |> User.changeset(params)
    |> Repository.update(@table_name)
  end


  defp validates_uniqueness(key, value) do
    case Repository.get(value, User, @table_name) do
      {:ok, _user} ->
        [{key,  "already taken"}]
      {:error, :not_found} ->
        []
      {:error, :cluster_down} ->
        [{key, "No users can currently be registered (the application runs in non-persistence mode)."}]
    end
  end
end
