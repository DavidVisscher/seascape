defmodule SeascapeIngest.WaveParserTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias SeascapeIngest.WaveParser

  describe "parse/1" do
    test "it does not crash for any of the example payloads" do
      example_payloads()
      |> Stream.map(&WaveParser.parse/1)
      |> Enum.each(fn events ->
        assert is_list(events)
        Enum.each(events, fn event ->
          assert match?(%{timestamp: timestamp, container_ref: container_ref, vm_hostname: vm_hostname}, event)

          # assert (
          #   match?("metrics." <> _, event[:key])
          #   or match?("meta." <> _, event[:key])
          # )
        end)
      end)
    end
  end

  def example_payloads do
      "./test/support/example_wave_output.json"
      |> File.stream!()
      |> Stream.map(&Jason.decode!/1)
  end
end
