defmodule SeascapeIngest.WaveParser.MetricsTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias SeascapeIngest.WaveParser.Metrics

  describe "parse_metric_num/1" do
    test "parses 0" do
      assert Metrics.parse_metric_num("0B") == {:ok, 0}
      assert Metrics.parse_metric_num("0kB") == {:ok, 0}
      assert Metrics.parse_metric_num("0kiB") == {:ok, 0}
      assert Metrics.parse_metric_num("0MB") == {:ok, 0}
      assert Metrics.parse_metric_num("0MiB") == {:ok, 0}
      assert Metrics.parse_metric_num("0GB") == {:ok, 0}
      assert Metrics.parse_metric_num("0GiB") == {:ok, 0}
    end


    property "no valid input is rejected" do
      check all num <- StreamData.float(min: 0),
                unit <- valid_units_gen() do
        str = "#{num}#{unit}"
        assert {:ok, _} = Metrics.parse_metric_num(str)
      end
    end

    property "for any 0 output is 0" do
      check all unit <- valid_units_gen() do
        str = "0#{unit}"
        assert {:ok, 0} = Metrics.parse_metric_num(str)
      end
    end
  end

  def valid_units_gen() do
    ~w[B kB kiB MB MiB GB GiB TB TiB]
    |> Enum.map(&StreamData.constant/1)
    |> StreamData.one_of()
  end

  describe "parse_percent/1" do
    property "for any valid input, output is in range 0..1" do
      check all val <- StreamData.float(min: 0, max: 100) do
        percent = "#{val}%"
        res = Metrics.parse_percent(percent)
        assert res >= 0
        assert res <= 1
      end
    end
  end

  describe "parse/1" do
    test "parses example JSON correctly into a list of metrics" do
      metrics =
        example_json()
        |> Metrics.parse()

      Enum.each(metrics, fn metric ->
        assert match?(%{key: key, vm_hostname: vm_hostname, container_ref: container_ref, value: _value} when is_binary(key) and is_binary(vm_hostname) and is_binary(container_ref), metric)
        case metrics[:key] do
          "metrics.docker_stats.memory.usage" ->
            assert_nonnegative_int(metrics[:value])
          "metrics.docker_stats.memory.limit" ->
            assert_nonnegative_int(metrics[:value])
          "metrics.docker_stats.network.in" ->
            assert_nonnegative_int(metrics[:value])
          "metrics.docker_stats.network.out" ->
            assert_nonnegative_int(metrics[:value])
          "metrics.docker_stats.block.in" ->
            assert_nonnegative_int(metrics[:value])
          "metrics.docker_stats.block.out" ->
            assert_nonnegative_int(metrics[:value])
          "metrics.docker_stats.cpu" ->
            assert_ratio_float(metrics[:value])
          "metrics.docker_stats.memory_percent" ->
            assert_ratio_float(metrics[:value])
          _other -> :ok
        end
      end)
    end
  end

  def assert_nonnegative_int(val) do
    assert is_integer(val)
    assert val >= 0
  end

  def assert_ratio_float(val) do
    assert is_float(val)
    assert val >= 0
    assert val <= 1
  end

  def example_json do
    "./test/support/example_wave_output_single_metrics_payload.json"
    |> File.read!()
    |> Jason.decode!()
  end
end
