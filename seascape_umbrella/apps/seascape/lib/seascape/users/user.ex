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
  @primary_key false
  schema "user" do
    field :email, :string, primary_key: true
    field :id, :binary_id
    field :password_hash,    :string
    field :current_password, :string, virtual: true
    field :password,         :string, virtual: true
    field :confirm_password, :string, virtual: true
  end

  # Allows us to use our struct with ElasticSearch
  # use Elastic.Document.API

  def new() do
    %__MODULE__{
      id: Ecto.UUID.generate()
    }
  end

  def changeset(user, changes \\ %{}) do
    user
    |> pow_changeset(changes)
  end
end
