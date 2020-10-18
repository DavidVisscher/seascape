defmodule SeascapeIngest.WaveParser do

  @doc """
  Parses a JSON datatype, which can be either of `meta` or `metrics`
  """
  def parse(json) do
    {timestamp, datatype, json} = prepare_json(json)
    {type, result} = case datatype do
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

  @doc """
  Parses the "metrics" JSON data that the Seascape Wave daemon sends over the wire.
  """
  def parse_meta(json) do
    json
    |> Enum.map(fn {key, v} -> {key, parse_machine_meta(v)} end)
    |> Enum.filter(&Function.identity/1)
    |> Enum.into(%{})
  end

  defp parse_machine_meta(json) do
    # :too_meta_for_me
    if json["docker"]["retcode"] != 0 do
      nil
    else
      data = json["docker"]["ret"]
      %{
        mem_total: data["MemTotal"]
      }
    end
  end

  @doc """
  Parses the "metrics" JSON data that the Seascape Wave daemon sends over the wire.
  """
  def parse_metrics(json) do
    json
    |> Enum.map(fn {key, v} ->
      {key, parse_machine_metrics(v)}
    end)
    |> Enum.filter(&Function.identity/1)
    |> Enum.into(%{})
  end

  defp parse_machine_metrics(json) do
    machine_metrics = %{
      cpu_percent: json["cpu_percent"]["ret"],
      cpu_times: json["cpu_times"]["ret"],
    }
    # IO.inspect(json["docker"]["ret"])
    container_metrics =
      if json["docker"]["retcode"] != 0 do
        []
      else
        json["docker"]["ret"]
        |> Enum.map(fn {k, v} -> {k, parse_container_metrics(v)} end)
      end
    {machine_metrics, container_metrics}
  end

  defp parse_container_metrics(json) do
    %{
      image: json["Image"],
      names: json["Names"],
      state: json["State"],
      status: json["Status"],
      time_created_epoch: DateTime.from_unix(json["Time_Created_Epoch"])
    }
  end
end
