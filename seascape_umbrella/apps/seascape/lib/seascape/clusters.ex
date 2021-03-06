defmodule Seascape.Clusters do
  alias __MODULE__.{Cluster, Machine, Container, ContainerMetric, MachineMetric}
  use CapturePipe
  alias Seascape.Repository

  @moduledoc """
  The `Clusters` DDD-context. Responsible for reading/writing cluster information/configuration.
  """


  # "hack" to ensure that ES does not return only a couple (e.g. 30) results
  # for queries where we want 'all' results immediately.
  @everything 10_000


  @doc """
  Fetches a cluster when its primary ID is known.

  Returns `{:ok, %Cluster{}}` or `{:error, problem}`.
  """
  def get_cluster(id) do
    Repository.get(id, Cluster)
  end

  @doc """
  Fetches a cluster based on a given API key.

  Returns `{:ok, %Cluster{}}` or `{:error, "API key invalid"}` when the key is not correct.
  """
  def get_cluster_by_api_key(api_key) do
    results = Repository.search(Cluster,
      %{
        query: %{
          bool: %{
            filter: [
              %{term: %{api_key: api_key}}
            ]
          }
        },
        size: 1
      })

    case results do
      {:ok, []} ->
        {:error, "API key invalid"}
      {:ok, [one_result]} ->
        {:ok, one_result}
      {:error, problem} ->
        {:error, problem}
    end
  end

  @doc """
  Searches for all machines of a given cluster ID.

  Returns `{:ok, list_of_machines}` or `{:error, problem}`
  """
  def get_cluster_machines(cluster_id) do
    Repository.search(Machine,
      %{
        query: %{
          bool: %{
            filter: %{term: %{cluster_id: cluster_id}}
          }
        },
        size: @everything
      })
  end

  @doc """
  Fetches a machine based on the encompassing cluster's ID and the machine's hostname.

  Returns `{:ok, %Machine{}}` or `{:error, problem}`.
  """
  def get_machine(cluster_id, hostname) do
    Machine.primary_key(cluster_id, hostname)
    |> Repository.get(Machine)
  end

  @doc """
  Searches for all containers of a given machine.

  Returns `{:ok, list_of_containers}` or `{:error, problem}`
  """
  def get_machine_containers(cluster_id, hostname) do
    key = Machine.primary_key(cluster_id, hostname)

    Repository.search(Container,
      %{
        query: %{
          bool: %{
            filter: %{term: %{machine_id: key}}
          }
        },
        size: @everything
      })
  end

  @doc """
  Fetches a container based on the encompassing cluster's ID, the encompassing machine's hostname, and the container's identifier.

  Returns `{:ok, %Machine{}}` or `{:error, problem}`.
  """
  def get_container(cluster_id, hostname, container_id) do
    Container.primary_key(cluster_id, hostname, container_id)
    |> Repository.get(Container)
  end

  @doc """
  Creates a new cluster for the given user.
  """
  def create_cluster(user, params) do
    result =
      Cluster.new(user.id)
      |> Cluster.changeset(params)
      |> Repository.create()
    case result do
      {:ok, result} ->
        Phoenix.PubSub.broadcast(Seascape.PubSub, "#{__MODULE__}/#{user.id}", {"persistent/cluster/created", %{"cluster" => result}})
        {:ok, result}
      other ->
        other
    end
  end

  @doc """
  Deletes an existing cluster
  """
  def delete_cluster(cluster) do
    Repository.delete(cluster)
  end

  @doc """
  Updates the contents of an existing cluster.
  """
  def update_custer(cluster, params) do
    cluster
    |> Cluster.changeset(params)
    |> Repository.update()
  end

  @doc """
  Search all clusters of a user.
  """
  def get_user_clusters(user) do
    case Repository.search(Cluster,
      %{query: %{
           match: %{
             user_id: user.id
           }
        },
        size: @everything
      }
        ) do
      {:ok, results} ->
        results
        |> Enum.map(fn cluster -> {cluster.id, cluster} end)
        |> Enum.into(%{})
        |> &{:ok, &1}
      other ->
        other
    end
  end

  @doc """
  When subscribed, process will be kept up-to-date
  of changes happening to all clusters of `user`.
  """
  def subscribe(user) do
    Phoenix.PubSub.subscribe(Seascape.PubSub, "#{__MODULE__}/#{user.id}")
  end

  def store_container_metric!(cluster_id, params) do
    ContainerMetric.new(cluster_id)
    |> ContainerMetric.changeset(params)
    |> Repository.create()
  end

  def store_machine_metric!(cluster_id, params) do
    MachineMetric.new(cluster_id)
    |> MachineMetric.changeset(params)
    |> Repository.create()
  end

  def store_container_metrics!(metrics_params, cluster_id, cluster_user_id) do
    structs =
      metrics_params
      |> Enum.map(fn map ->
        cluster_id
        |> ContainerMetric.new()
        |> ContainerMetric.changeset(map)
      end)
    Task.start(fn ->
      Phoenix.PubSub.broadcast(Seascape.PubSub, "#{__MODULE__}/#{cluster_user_id}", {"persistent/cluster/#{cluster_id}/metrics", structs})
    end)
    Task.start(fn ->
      Repository.bulk_create(structs)
    end)
  end

  def get_metrics(cluster_id, ago \\ "10m") do
    Repository.search(ContainerMetric, get_metrics_query(cluster_id, ago))
  end

  defp get_metrics_query(cluster_id, ago \\ "10m") do
    %{size: @everything,
      query: %{
        bool: %{
          must: [
            %{match: %{cluster_id: cluster_id}},
          ],
          filter: [
            %{range: %{timestamp: %{gte: "now-#{ago}"}}}
          ]
        }
      }}
  end

  def get_metrics_aggregates(cluster_id, ago \\ "10m", interval \\ "1m") do
    query =
      get_metrics_query(cluster_id, ago)
      |> put_in([:size], 0)
      |> put_in([:aggs], get_aggs_query(interval))

    with {:ok, result} <- Repository.search(ContainerMetric, query, extract_hits: false) do
      {:ok, result["aggregations"]}
    end
  end

  def get_metrics_flat_aggregates(cluster_id, ago \\ "5m") do
    query =
      get_metrics_query(cluster_id, ago)
      |> put_in([:size], 0)
      |> put_in([:aggs], inner_get_aggs_query())

    with {:ok, result} <- Repository.search(ContainerMetric, query, extract_hits: false) do
      {:ok, result["aggregations"]}
    end
  end

  def get_clusterwide_metrics_aggregates(cluster_id, ago \\ "5m") do
    query =
      get_metrics_query(cluster_id, ago)
      |> put_in([:size], 0)
      |> put_in([:aggs], 
    %{"per_container": %{
         "terms": %{
           "field": "container_ref",
           "size": @everything
         },
         "aggs": %{
           "max_block_in": %{
             "max": %{
               "field": "data.metrics.docker_stats.block.in"
             }
           },
           "max_block_out": %{
             "max": %{
               "field": "data.metrics.docker_stats.block.out"
             }
           },
           "max_network_in": %{
             "max": %{
               "field": "data.metrics.docker_stats.network.in"
             }
           },
           "max_network_out": %{
             "max": %{
               "field": "data.metrics.docker_stats.network.out"
             }
           },
         }
      }
    }
    )

    with {:ok, %{"aggregations" => %{"per_container" => %{"buckets" => container_agg}}}} <- Repository.search(ContainerMetric, query, extract_hits: false) do
      res = Enum.reduce(container_agg, %{max_block_in: 0, max_block_out: 0, max_network_in: 0, max_network_out: 0}, fn elem, acc ->
        %{
          max_block_in: acc[:max_block_in] + elem["max_block_in"]["value"],
          max_block_out: acc[:max_block_out] + elem["max_block_out"]["value"],
          max_network_in: acc[:max_network_in] + elem["max_network_in"]["value"],
          max_network_out: acc[:max_network_out] + elem["max_network_out"]["value"]
         }
      end)
      {:ok, res}
      # {:ok, result["aggregations"]}
    end
  end

  def get_aggs_query(interval \\ "1m") do
    %{"metrics_per_minute": %{
        "date_histogram": %{
          "field": "timestamp",
          "calendar_interval": interval
        },
        "aggs": inner_get_aggs_query()
      }
    }
  end

  def inner_get_aggs_query() do
    %{
      "per_container": %{
        "terms": %{
          "field": "container_ref",
          "size": @everything
        },
        "aggs": inner_inner_get_aggs_query()
      }
    }
  end

  def inner_inner_get_aggs_query() do
    %{
      "avg_cpu_percent": %{
        "avg": %{
          "field": "data.metrics.docker_stats.cpu.percent"
        }
      },
      "avg_mem_usage": %{
        "avg": %{
          "field": "data.metrics.docker_stats.memory.usage"
        }
      },
      "avg_block_in": %{
        "avg": %{
          "field": "data.metrics.docker_stats.block.in"
        }
      },
      "avg_block_out": %{
        "avg": %{
          "field": "data.metrics.docker_stats.block.out"
        }
      },
      "avg_mem_percent": %{
        "avg": %{
          "field": "data.metrics.docker_stats.memory.percent"
        }
      }
    }
  end
end
