defmodule Seascape.Users.User do
  @moduledoc """
  Datastructure representing an (authorized) user.
  Represented in the database.
  """
  use Ecto.Schema
  use Pow.Ecto.Schema,
    password_hash_methods: {&Pow.Ecto.Schema.Password.pbkdf2_hash/1,
                            &Pow.Ecto.Schema.Password.pbkdf2_verify/2}
  @derive {Jason.Encoder, except: [:__meta__]}

  # @required_fields [:email, :password_hash]
  @primary_key false
  schema "users" do
    field :email, :string, primary_key: true
    field :password_hash,    :string
    field :current_password, :string, virtual: true
    field :password,         :string, virtual: true
    field :confirm_password, :string, virtual: true

  end

  # Allows us to use our struct with ElasticSearch
  @es_type "seascape_user"
  @es_index "user"
  # use Elastic.Document.API

  def new() do
    %__MODULE__{}
  end

  def changeset(user, changes \\ %{}) do
    user
    |> pow_changeset(changes)
  end
end
