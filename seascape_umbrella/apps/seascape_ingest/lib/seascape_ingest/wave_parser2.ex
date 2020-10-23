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

  def parse_meta(json) do
  end
end
