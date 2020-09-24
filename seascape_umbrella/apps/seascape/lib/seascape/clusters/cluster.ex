defmodule Seascape.Clusters.Cluster do
  @moduledoc """
  Datastructure representing a cluster of zero or more user nodes.
  Used to keep track of cluster-wide info.
  """

  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__meta__]}
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "cluster" do
    field :user_id, :binary_id
    field :name, :string
    field :api_key, :binary_id
  end

  def new(user_id) do
    %__MODULE__{
      user_id: user_id,
      id: Ecto.UUID.generate()
      api_key: Ecto.UUID.generate()
    }
  end

  def changeset(cluster, changes \\ {}) do
    cluster
    |> Ecto.Changeset.cast(changes, [:name])
  end
end
