defmodule Seascape.Users.User do
  @moduledoc """
  Datastructure representing an (authorized) user.
  Represented in the database.
  """
  use Ecto.Schema
  use Pow.Ecto.Schema
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
  @es_index "seascape_user"
  use Elastic.Document.API



  # defstruct [:id, email: nil, password_hash: nil]

  # use Ecto.Schema
  # use Pow.Ecto.Schema

  def changeset(user, changes \\ %{}) do
    user
    |> pow_changeset(changes)
    # |> Ecto.Changeset.cast(changes, [:email, :password_hash])
    # |> Ecto.Changeset.validate_required([:email])
    # |> Pow.Ecto.Schema.Changeset.user_id_field_changeset(changes, @pow_config)
    # |> Pow.Ecto.Schema.Changeset.current_password_changeset(changes, @pow_config)
    # |> Pow.Ecto.Schema.Changeset.password_changeset(changes, @pow_config)
  end

  def verify_password(user, password) do
    Pow.Ecto.Schema.Changeset.verify_password(user, password, nil)
  end
end
