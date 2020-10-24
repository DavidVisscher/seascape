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

  Note the calls to `Repository.refresh`
  this strengthens the 'session consistency'
  by waiting to return until the indices referring to the user
  have been refreshed, making it less likely
  that the user might e.g. register an account and then have to wait
  for eventual consistency to kick in 'later'
  before they will be able to log in.
  """

  def get(email) do
    Repository.get(email, User)
  end

  def create(params) do
    result =
      User.new()
      |> User.changeset(params)
      |> Ecto.Changeset.validate_change(User.pow_user_id_field, &validates_uniqueness/2)
      |> Repository.create()
    Repository.refresh()
    result
  end

  def delete(user) do
    result = Repository.delete(user)
    Repository.refresh()
    result
  end

  def update(user, params) do
    result =
      user
      |> User.changeset(params)
      |> Repository.update()

    Repository.refresh()
    result
  end


  defp validates_uniqueness(key, value) do
    case Repository.get(value, User) do
      {:ok, _user} ->
        [{key,  "already taken"}]
      {:error, :not_found} ->
        []
      {:error, :cluster_down} ->
        [{key, "No users can currently be registered (the application runs in non-persistence mode)."}]
    end
  end
end
