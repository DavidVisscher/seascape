defmodule Seascape.Clusters.Cluster do
  @moduledoc """
  Datastructure representing a cluster of zero or more user nodes.
  Used to keep track of cluster-wide info.
  """

  use Ecto.Schema
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "clusters" do
    field :user_id, :binary_id
    field :name, :string
  end

  def new() do
    %__MODULE__{}
  end

  def changeset(cluster, changes \\ {}) do
    cluster
    |> cast(changes, [:name])
  end
end
