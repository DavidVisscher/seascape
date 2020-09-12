defmodule Seascape.Users.User do
  @moduledoc """
  Datastructure representing an (authorized) user.
  Represented in the database.
  """
  use Ecto.Schema

  @required_fields [:email, :password_hash]
  schema "users" do
    field :email, :string
    field :password_hash, :string
  end


  # defstruct [:id, email: nil, password_hash: nil]

  # use Ecto.Schema
  # use Pow.Ecto.Schema

  def changeset(user, changes \\ %{}) do
    user
    |> Ecto.Changeset.cast(changes, [:email, :password_hash, :id])
    |> Ecto.Changeset.validate_required([:email])
    |> Ecto.Changeset.put_change(:id, 42)
  end

  def verify_password(user, password) do
    password == "topsecret"
  end

  def pow_user_id_field do
    :email
  end
end
