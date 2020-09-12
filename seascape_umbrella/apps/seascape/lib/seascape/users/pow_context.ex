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

    case User.get(user_id_field) do
      nil ->
        verify_password(%User{}, password) # Prevent timing attacks
      user = %User{} ->
        verify_password(user, password)
    end
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
    # user = Ecto.Changeset.apply_action!(user, :create)
    user = apply_changeset(user, :create)
    IO.inspect(user, label: :do_create)
    case User.get(user.email) do
      %User{} ->
        {:error, nil}
      nil ->
        put_in(user.password, nil) # Do not store virtual fields
        Seascape.Users.User.index(user.email , user)
        {:ok, user}
    end
  end

  def delete(user) do
    IO.inspect(user, label: :delete)
    Seascape.Users.User.delete(user.email)
  end

  def get_by(clauses) do
    IO.inspect(clauses, label: :get_by)
  end

  def update(user, params) do
    IO.inspect({user, params}, label: :update)

    user =
      user
      |> User.changeset(params)
      # |> Ecto.Changeset.apply_action!(:update)
      |> apply_changeset(:update)
    Seascape.Users.User.update(user.email, user)
  end

  defp apply_changeset(changeset, action) do
    user = Ecto.Changeset.apply_action!(changeset, action)
    Enum.reduce(user |> Map.from_struct |> Map.keys, user, fn key, user ->
      if key not in User.__schema__(:fields) do
        put_in(user, [Access.key(key)], nil)
      else
        user
      end
    end)
    # for field in (user |> Map.from_struct |> Map.keys) do
    #   User.__schema__(:fields)
  end
end
