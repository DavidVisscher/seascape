defmodule Seascape.Users.PowContext do
  alias Seascape.Users
  alias Seascape.Users.User

  @moduledoc """
  Wrapper of the `SeaScape.Users` context to be used with the interface
  that the `Pow` authentication library provides.
  """

  def authenticate(params) do
    user_id_field = User.pow_user_id_field
    user_id_value = params[Atom.to_string(user_id_field)]
    password = params["password"]

    do_authenticate(user_id_field, user_id_value, password)
  end

  defp do_authenticate(_, nil, _), do: nil
  defp do_authenticate(_user_id_field, user_id_value, password) do
    case Users.get(user_id_value) do
      {:error, :not_found} ->
        # Prevent timing attacks by running a 'useless' verification:
        verify_password(User.new(), password)
      {:ok, user = %User{}} ->
        verify_password(user, password)
    end
  end

  defp verify_password(user, password) do
    case User.verify_password(user, password) do
      true -> user
      false -> nil
    end
  end

  def create(params) do
    Users.create(params)
  end

  def delete(user) do
    Users.delete(user)
  end

  def update(user, params) do
    Users.update(user, params)
  end

  def get_by(clauses) do
    IO.inspect(clauses, label: :get_by)
  end

  def changeset(params) do
    IO.inspect(params, label: :changeset)
  end
end
