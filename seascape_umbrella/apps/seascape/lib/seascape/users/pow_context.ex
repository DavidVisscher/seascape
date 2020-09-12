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

    case User.get(user_id_value) do
      nil ->
        verify_password(%User{}, password) # Prevent timing attacks
      user = %User{} ->
        verify_password(user, password)
    end
  end

  defp verify_password(user, password) do
    IO.inspect({user, password}, label: :verify_password)
    case User.verify_password(user, password) do
      true -> user
      false -> nil
    end
    |> IO.inspect(label: :verify_password_result)
  end

  def changeset(params) do
    IO.inspect(params, label: :changeset)
  end

  def create(params) do
    IO.inspect(params, label: :create)

    User
    |> struct()
    |> User.changeset(params)
    |> Ecto.Changeset.validate_change(:email, &validates_uniqueness/2)
    |> do_create()
  end

  defp do_create(changeset) do
    IO.inspect(changeset, label: :do_create)
    case apply_changeset(changeset, :create) do
      {:error, problem} ->
        {:error, problem}
      {:ok, user} ->
        Seascape.Users.User.index(user.email , user)
        {:ok, user}
    end
  end

  def validates_uniqueness(:email, email) do
    case User.get(email) do
      %User{} ->
        [email: "already taken"]
      nil ->
        []
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
