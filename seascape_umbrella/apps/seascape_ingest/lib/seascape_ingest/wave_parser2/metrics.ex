defmodule SeascapeIngest.WaveParser2.Metrics do
  def parse_metric(str) do
    val =
      str
      |> String.trim
      |> Float.parse()
    case val do
      :error -> :error
      {float, unit_str} ->

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
