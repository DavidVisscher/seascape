defmodule Seascape.Clusters.Container do
  alias Seascape.Clusters.Machine
  @moduledoc """
  Datastructure representing information of a single container in a `Seascape.Clusters.Machine`.
  """

  use Ecto.Schema
  @derive {Jason.Encoder, except: [:__meta__]}
  @primary_key false
  schema "containers" do
    field :machine_id, :string, primary_key: true
    field :id, :string, primary_key: true
  end

  def new(machine_id) do
    %__MODULE__{
      machine_id: machine_id
    }
  end

  def changeset(container, changes \\ %{}) do
    container
    |> Ecto.Changeset.cast(changes, [:id])
  end

  def primary_key(struct = %__MODULE__{}) do
    primary_key(struct.machine_id, struct.id)
  end

  def primary_key(machine_id, id) do
    "#{machine_id}/#{id}"
  end

  def primary_key(cluster_id, hostname, container_id) do
    Machine.primary_key(cluster_id, hostname)
    |> primary_key(container_id)
  end
end
