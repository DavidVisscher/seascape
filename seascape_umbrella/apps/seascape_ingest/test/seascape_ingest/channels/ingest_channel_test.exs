defmodule SeascapeIngest.IngestChannelTest do
  use SeascapeIngest.ChannelCase
  alias SeascapeIngest.{ApiSocket, IngestChannel}

  setup_all do
    IO.puts("Creating example cluster data in ElasticSearch")
    Seascape.Repository.delete_all(Seascape.Clusters.ContainerMetric)

    {:ok, cluster} = Seascape.Clusters.create_cluster(%{id: "848ea06f-9779-43f2-a15b-7080aeb02af5"}, %{name: "testcluster"})
    Seascape.Repository.refresh_all # Since we'll need the data immediately in tests
    [cluster: cluster]
  end

  test "Connecting with invalid API key results in error" do
    {:ok, socket} = connect(ApiSocket, %{}, %{})
    connection_result = subscribe_and_join(socket, "ingest", %{"api_key" => "fake"})
    assert {:error, %{reason: "unknown API key"}} == connection_result
  end

  test "Connecting with valid API key results in the cluster id being set on the socket", context do
    cluster = context[:cluster]

    {:ok, socket} = connect(ApiSocket, %{}, %{})
    {:ok, _, socket} = subscribe_and_join(socket, "ingest", %{"api_key" => cluster.api_key})
    assert socket.assigns.cluster_id == cluster.id
  end

  test "Sending a websocket message with `metrics` as topic will result in container_metrics being added to the DB", context do
    cluster = context[:cluster]

    {:ok, socket} = connect(ApiSocket, %{}, %{})
    {:ok, _, socket} = subscribe_and_join(socket, "ingest", %{"api_key" => cluster.api_key})
    old_count = count_metrics()

    example_payloads()
    |> Enum.map(fn payload ->
      ref = push(socket, "metrics", payload)
      assert_reply ref, :ok, _, 200
    end)

    # TODO assert that changes were pushed to repo

    new_count = count_metrics()
    assert new_count > old_count
  end

  def example_payloads do
    "./test/support/example_wave_output.json"
    |> File.stream!()
    |> Stream.map(&Jason.decode!/1)
  end

  defp count_metrics() do
    Seascape.Repository.refresh_all # Since we'll need the data immediately in tests
    {:ok, 200, %{"count" => count}} = Elastic.HTTP.post("/seascape_container_metrics/_count")
    count
    end
end
