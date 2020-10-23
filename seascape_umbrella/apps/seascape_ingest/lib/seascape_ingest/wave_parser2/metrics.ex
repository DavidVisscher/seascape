defmodule SeascapeIngest.WaveParser2.Metrics do
  def parse(json) do
    json
    |> Enum.flat_map(fn {vm_hostname, container_json} -> parse_vm(vm_hostname, container_json) end)
    |> Enum.map(&update_in(&1[:key], fn key -> "metrics.#{key}" end))
  end

  def parse_vm(vm_hostname, vm_json) do
    # We're not yet parsing cpu_percent, cpu_times here
    (vm_json["docker_stats"] || [])
    |> Enum.flat_map(&parse_container(vm_hostname, &1))
  end

  def parse_container(_vm_hostname, nil), do: [] # Called for VMs without containers
  def parse_container(vm_hostname, container_json) do
    container_json
    |> parse_container_docker_stats()
    |> Enum.map(&put_in(&1[:vm_hostname], vm_hostname))
  end

  def parse_container_docker_stats(json = %{"container" => container_hash, "name" => container_name}) do
    container_ref = container_hash <> ":" <> container_name
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
    |> Enum.map(fn {key, val} -> {"docker_stats.#{key}", val} end)
    |> Enum.map(fn {key, val} ->
      # We use the property that `container_hash` never contains a `:` here.
      # to ensure we store both fields in a single string
      %{container_ref: container_ref, key: key, value: val}
    end)
  end

  def parse_memory_percent(nil), do: []
  def parse_memory_percent(str) when is_binary(str) do
    ["memory.percent": parse_percent(str)]
  end

  def parse_cpu(nil), do: []
  def parse_cpu(str) when is_binary(str) do
    ["cpu.percent": parse_percent(str)]
  end

  def parse_memory(nil), do: []
  def parse_memory(json = %{}) do
    [
      "memory.usage": parse_metric_num!(json["usage"]),
      "memory.limit": parse_metric_num!(json["limit"])
    ]
  end

  def parse_network_io(nil), do: []
  def parse_network_io(json = %{}) do
    [
      "network.in": parse_metric_num!(json["in"]),
      "network.out": parse_metric_num!(json["out"])
    ]
  end

  def parse_block_io(nil), do: []
  def parse_block_io(json = %{}) do
    [
      "block.in": parse_metric_num!(json["in"]),
      "block.out": parse_metric_num!(json["out"])
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

  def parse_metric_num!(str) do
    {:ok, res} = parse_metric_num(str)
    res
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
