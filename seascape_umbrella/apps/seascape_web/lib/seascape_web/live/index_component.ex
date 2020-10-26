defmodule SeascapeWeb.IndexComponent do
  use SeascapeWeb, :live_component
  use CapturePipe

  def mb_stat(float) do
    val =
      float / (1000 * 1000)
      |> round()
  end
end
