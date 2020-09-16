defmodule Mix.Tasks.Seascape.CreateElasticsearchIndexes do
  use Mix.Task

  @shortdoc "Creates all not-yet-existent ElasticSearch(ES) indexes in the ES cluster."
  def run(_) do
    Mix.Task.run("app.start")
    IO.puts("Creating missing ElasticSearch indexes...")

    idempotently_create_index("users")
    idempotently_create_index("clusters")
    idempotently_create_index("nodes")

    IO.puts("fully done!")
  end

  defp idempotently_create_index(name) do
    full_name = Elastic.Index.name(name)
    if Elastic.Index.exists?(full_name) do
      IO.puts("  Skipping ElasticSearch index #{full_name} as it already exists.")
    else
      IO.write("  Creating ElasticSearch index #{full_name}...")
      Elastic.Index.create(full_name)
      IO.puts(" done!")
    end
  end
end
