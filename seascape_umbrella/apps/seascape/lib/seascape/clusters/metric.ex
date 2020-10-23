defmodule Seascape.Clusters.Metric do
  @moduledoc """
  A KISS {host, key, timestamp, value}-store
  for data obtained from SeaScape Wave.
  """

  use Ecto.Schema

  @derive {Jason.Encoder, except: [:__meta__]}
  @primary_key {:id, :binary_id, autogenerate: false}
  schema "metrics" do
    field :cluster_id, :binary_id
    field :host, :string
    field :timestamp, :utc_datetime_usec
    field :key, :string
    field :value, :string
  end

  def new(cluster_id) do
    %__MODULE__{
      id: Ecto.UUID.generate(),
      cluster_id: cluster_id
    }
  end

  def changeset(metric, changes \\ %{}) do
    metric
    |> Ecto.Changeset.cast(changes, [:host, :timestamp, :key, :value])
    |> Ecto.Changeset.validate_required([:host, :timestamp, :key, :value])
  end
end
