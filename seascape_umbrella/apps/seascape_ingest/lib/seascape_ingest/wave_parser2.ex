defmodule SeascapeIngest.WaveParser2 do
  alias __MODULE__.Metrics
  @doc """
  Parses a JSON datatype, which can either be a `metrics` message,
  containing only "docker ps" output

  or `meta` which contains a much larger output.
  """
  def parse(json) do
    {timestamp, datatype, clean_json} = prepare_json(json)
    case datatype do
      "metrics" ->
        Metrics.parse(clean_json)
      "meta" ->
        # {:meta, parse_meta(json)}
        []
    end
    |> Enum.map(&put_in(&1[:timestamp], timestamp))
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
end
