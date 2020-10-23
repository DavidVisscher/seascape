defmodule SeascapeIngest.WaveParser2 do
  @doc """
  Parses a JSON datatype, which can either be a `metrics` message,
  containing only "docker ps" output

  or `meta` which contains a much larger output.
  """
  def parse(json) do
    {timestamp, datatype, json} = prepare_json(json)
    {type, result} =
      case datatype do
        "metrics" ->
          {:metrics, parse_metrics(json)}
        "meta" ->
          {:meta, parse_meta(json)}
      end
    {type, result, timestamp}
  end

  defp prepare_json(json) do
    timestamp = NaiveDateTime.from_iso8601!(json["timestamp"])
    datatype = json["ss_datatype"]
    clean_json =
      json
      |> Map.delete("ss_datatype")
      |> Map.delete("timestamp")
    {timestamp, datatype, clean_json}
  end

  def parse_metrics(json) do
  end

  def parse_metrics_container(container_json) do
  end

  def parse_metrics_container_docker_stats(container_json) do
    container_json["docker_stats"]
    |> Enum.map(fn docker_json ->
      name = docker_json["name"]
      container = docker_json["container"]
      # memory = parse_memory(docker_json["memory"])
      # block_io = parse_memory(docker_json["memory"])
      # network_io = parse_memory(docker_json["memory"])
      cpu = docker_json["cpu"]

      {name, %{
          container: container,
          # memory: memory,
          # block_io: block_io,
          # network_io: network_io,
          cpu: cpu
       }}
    end)
  end

  # def parse_memory(memory_json) do
  # end

  # def parse_block_io(block_json) do
  # end

  def parse_meta(json) do
    %{}
  end
end
