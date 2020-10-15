defmodule Seascape.Repository.ElasticSearch.Watchdog do
  @moduledoc """
  Keeps track of the health of the ElasticSearch cluster,
  to degrade service this node can provide when the cluster (or the connection to it) has problems.
  """
  require Logger
  use GenServer
  use CapturePipe

  @seconds_between_pings 3
  @required_consecutive_successes 3
  @initial_state %{status: :disconnected, consecutive_successes: @required_consecutive_successes}

  def start_link(_) do
    GenServer.start_link(__MODULE__, @initial_state, name: __MODULE__)
  end


  def cluster_ok?() do
    GenServer.call(__MODULE__, :cluster_ok?)
  end

  def handle_call(:cluster_ok?, _from, state) do
    result = state.status == :connected
    {:reply, result, state}
  end

  def init(state) do
    {:ok, state, {:continue, nil}}
  end

  def handle_continue(_, state) do
    state
    |> perform_check()
    |> &{:noreply, &1}
  end

  def handle_info(:perform_check, state) do
    state
    |> perform_check()
    |> &{:noreply, &1}
  end

  defp perform_check(state) do
    Process.send_after(self(), :perform_check, ping_timeout())
    case {state.status, check()} do
      {:connected, :connected} ->
        %{status: :connected}
      {:connected, :disconnected} ->
        Logger.error("Connection with ElasticSearch lost!")
        Phoenix.PubSub.broadcast(Seascape.PubSub, "Seascape.Repository/health", {"ephemeral/repository/connected", false})
        @initial_state
      {:disconnected, :disconnected} ->
        @initial_state
      {:disconnected, :connected} ->
        if state.consecutive_successes < @required_consecutive_successes do
          update_in(state.consecutive_successes, &(&1 + 1))
        else
          Logger.error("Connection with ElasticSearch (re-)established")
          Phoenix.PubSub.broadcast(Seascape.PubSub, "Seascape.Repository/health", {"ephemeral/repository/connected", true})
          %{status: :connected}
        end
    end
  end

  defp ping_timeout() do
    @seconds_between_pings + jitter()
    |> &(&1 * 1000)
    |> round()
  end

  defp jitter() do
    :rand.uniform() * 10
  end

  defp check() do
    case Elastic.HTTP.get("_cluster/health/") do
      {:ok, 200, %{"status" => status}} when status in ~w(green yellow) ->
        :connected
      _other ->
        :disconnected
    end
  end
end
