defmodule Seascape.Clusters.Machine do
  @moduledoc """
  Datastructure representing a single (potentially virtual) machine containing one or more containers.

  Used to keep track of machine-wide information like general memory statistics,
  and to group `Seascape.Clusters.Container`s.
  """

  use Ecto.Schema
  @derive {Jason.Encoder, except: [:__meta__]}
  @primary_key false
  schema "machines" do
    field :cluster_id, :binary_id, primary_key: true
    field :hostname, :string, primary_key: true
  end

  def new(cluster_id) do
    %__MODULE__{
      cluster_id: cluster_id,
    }
  end

  def changeset(machine, changes \\ %{}) do
    machine
    |> Ecto.Changeset.cast(changes, [:ip])
  end

  def primary_key(struct = %__MODULE__{}) do
    primary_key(struct.cluster_id, struct.hostname)
  end

  def primary_key(cluster_id, hostname) do
    "#{cluster_id}/#{hostname}"
  end
end
