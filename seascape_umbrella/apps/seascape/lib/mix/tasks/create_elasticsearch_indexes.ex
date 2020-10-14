defmodule Mix.Tasks.Seascape.CreateElasticsearchIndexes do
  use Mix.Task

  @shortdoc "Creates all not-yet-existent ElasticSearch(ES) indexes in the ES cluster."
  def run(_) do
    Mix.Task.run("app.start")
    IO.puts("Creating missing ElasticSearch indexes...")
    Process.sleep(1000)

    idempotently_create_index("users", %{mappings: %{properties: %{id: %{type: :keyword}}}})
    idempotently_create_index("clusters",
      %{mappings: %{properties: %{
           api_key: %{type: :keyword},
           id: %{type: :keyword}}
    }})

    idempotently_create_index("nodes")

    IO.puts("fully done!")
  end

  defp idempotently_create_index(name, params \\ []) do
    full_name = Elastic.Index.name(name)
    if Elastic.Index.exists?(name) do
      IO.puts("  Skipping ElasticSearch index #{full_name} as it already exists.")
    else
      IO.write("  Creating ElasticSearch index #{full_name}...")
      Elastic.Index.create(name, params)
      IO.puts(" done!")
    end
  end
end
