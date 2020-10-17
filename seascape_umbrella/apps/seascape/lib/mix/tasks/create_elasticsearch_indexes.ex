defmodule Mix.Tasks.Seascape.CreateElasticsearchIndexes do
  use Mix.Task

  @shortdoc "Creates all not-yet-existent ElasticSearch(ES) indexes in the ES cluster."
  def run(_) do
    Mix.Task.run("app.start")
    Process.sleep(1000)
    IO.puts("Creating missing ElasticSearch indexes...")

    idempotently_create_index("users", %{mappings: %{properties: %{id: %{type: :keyword}}}})
    idempotently_create_index("clusters",
      %{mappings: %{properties: %{
           api_key: %{type: :keyword},
           id: %{type: :keyword}}
    }})

    idempotently_create_index("machines",
      %{ mappings: %{properties: %{
                        id: %{type: :keyword},
                        cluster_id: %{type: :keyword},
    }}})
    idempotently_create_index("containers",
      %{mappings: %{properties: %{
                       machine_id: %{type: :keyword},
      }}})

    IO.puts("fully done!")
  end

  defp idempotently_create_index(name, params) do
    full_name = Elastic.Index.name(name)
    if Elastic.Index.exists?(name) do
      IO.puts("  Skipping ElasticSearch index #{full_name} as it already exists.")
    else
      IO.write("  Creating ElasticSearch index #{full_name}...")
      res = Elastic.Index.create(name, params)
      case res do
        {:error, _, _} ->
          IO.puts("Unexpected result: ")
          IO.inspect(res)
          IO.puts("Stopping immediately")
          System.halt()
        _ ->
          IO.puts(" done!")
      end
    end
  end
end
