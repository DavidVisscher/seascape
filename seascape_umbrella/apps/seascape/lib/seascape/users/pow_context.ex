defmodule Seascape.Users.PowContext do
  alias Seascape.Users.User
  def authenticate(params) do
    IO.inspect(params, label: :authenticate)
    
    user_id_field = User.pow_user_id_field
    user_id_value = params[Atom.to_string(user_id_field)]
    password = params["password"]

    do_authenticate(user_id_field, user_id_value, password)

    # nil
  end

  defp do_authenticate(_, nil, _), do: nil
  defp do_authenticate(user_id_field, user_id_value, password) do
    result = %User{email: user_id_value, id: 42} # perform DB query
    verify_password(result, password)
  end

  defp verify_password(user, password) do
    case User.verify_password(user, password) do
      true -> user
      false -> nil
    end
  end

  def changeset(params) do
    IO.inspect(params, label: :changeset)
  end

  def create(params) do
    IO.inspect(params, label: :create)

    User
    |> struct()
    |> User.changeset(params)
    |> IO.inspect
    |> do_create()
  end

  defp do_create(user) do
    # Error handling/query making based on ElasticSearch
    {:ok, user}
  end

  def delete(user) do
    IO.inspect(user, label: :delete)
  end

  def get_by(clauses) do
    IO.inspect(clauses, label: :get_by)
  end

  def update(user, params) do
    IO.inspect({user, params}, label: :update)
  end
end
