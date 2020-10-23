defmodule SeascapeIngest.WaveParser2.Metrics do
  def parse(json) do
    docker_stats = parse_docker_stats(hd json["docker_stats"])
    # TODO potentially measure CPU times data

    docker_stats
    |> Enum.map(fn {key, val} -> {"metrics.#{key}", val} end)
  end

  def parse_docker_stats(json) do
    res =
    (
      parse_memory_percent(json["memory_percent"])
      ++
      parse_cpu(json["cpu"])
      ++
      parse_memory(json["memory"])
      ++
      parse_network_io(json["network_id"])
      ++
      parse_block_io(json["block_io"])
    )

    res
    |> Enum.map(fn {key, val} -> {"docker_stats.#{key}", val} end)
  end

  def parse_memory_percent(str) do
    ["memory.percent": parse_percent(str)]
  end

  def parse_cpu(str) do
    ["cpu.percent": parse_percent(str)]
  end

  def parse_memory(json) do
    [
      "memory.usage": parse_metric_num(json["usage"]),
      "memory.limit": parse_metric_num(json["limit"])
    ]
  end

  def parse_network_io(json) do
    [
      "network.in": parse_metric_num(json["in"]),
      "network.out": parse_metric_num(json["out"])
    ]
  end

  def parse_block_io(json) do
    [
      "block.in": parse_metric_num(json["in"]),
      "block.out": parse_metric_num(json["out"])
    ]
  end

  def parse_percent(str) do
    case Float.parse(str) do
      {float, "%"} ->
        float / 100
      _other ->
        raise "Invalid metrics: could not parse `#{str}`"
    end
  end

  def parse_metric_num(str) do
    val =
      str
      |> String.trim
      |> Float.parse()
    case val do
      :error -> raise "Invalid metrics: could not parse `#{str}`"
      {float, unit_str} ->
        {:ok, round(float * parse_unit(unit_str))}
    end
  end

  prefixes = %{
    "": 0,
    k: 1,
    M: 2,
    G: 3,
    T: 4,
  }

  for {prefix, exponent} <- prefixes do
    match = "#{prefix}B"
    def parse_unit(unquote(match)) do
      1000
      |> Math.pow(unquote(exponent))
      |> round
    end

    match = "#{prefix}iB"
    def parse_unit(unquote(match)) do
      1024
      |> Math.pow(unquote(exponent))
      |> round
    end
  end
end
