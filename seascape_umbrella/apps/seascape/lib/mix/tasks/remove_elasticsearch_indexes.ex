defmodule Mix.Tasks.Seascape.RemoveElasticsearchIndexes do
  use Mix.Task

  @shortdoc "Removes all indexes that Seascape uses. Don't run this on production!"
  def run(_) do
    Mix.Task.run("app.start")
    Process.sleep(1000)
    IO.puts("Deleting ElasticSearch indexes...")

    delete_index("containers")
    delete_index("machines")
    delete_index("clusters")
    delete_index("users")

    IO.puts("fully done!")
  end

  def delete_index(name) do
    full_name = Elastic.Index.name(name)
    if !Elastic.Index.exists?(name) do
      IO.puts("  Skipping ElasticSearch index #{full_name} as it does not exist.")
    else
      IO.write(  "Deleting #{full_name}...")
      res = Elastic.Index.delete(name)
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
