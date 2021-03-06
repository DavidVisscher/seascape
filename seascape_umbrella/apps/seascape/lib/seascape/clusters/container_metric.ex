defmodule Seascape.Clusters.ContainerMetric do
  @moduledoc """
  A KISS {host, key, timestamp, value}-store
  for data obtained from SeaScape Wave.
  """

  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__meta__]}
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "container_metrics" do
    field :cluster_id, :binary_id
    field :hostname, :string
    field :container_ref, :string # Contains `alphanumeric_hash:arbitrary_string`
    field :timestamp, :utc_datetime_usec
    field :data, :map
  end

  def new(cluster_id) do
    %__MODULE__{
      id: Ecto.UUID.generate(),
      cluster_id: cluster_id,
      data: %{}
    }
  end

  def changeset(metric, changes \\ %{}) do
    metric
    |> Ecto.Changeset.cast(changes, [:hostname, :container_ref, :timestamp, :data])
    |> Ecto.Changeset.validate_required([:hostname, :container_ref, :timestamp, :data])
  end
end
