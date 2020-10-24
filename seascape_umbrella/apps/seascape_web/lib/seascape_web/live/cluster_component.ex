defmodule SeascapeWeb.ClusterComponent do
  use SeascapeWeb, :live_component
  use CapturePipe

  @doc """
  expects `points` to be an enumerable where each elements is an `%{x: key, y: value}`-map.
  """
  def time_line_chart(id, label, points, options \\ %{data: %{}}, assigns) do
    type = "line"
    data = Map.merge(options[:data], %{
      datasets: [%{
                    label: label,
                    data: points,
                 }]
    })
    options = Map.merge(%{scales: %{ xAxes: [%{type: "time"}]}}, options)
    chart(id, type, data, options, assigns)
  end


  @doc """
  Build a Chart using Charts.js
  expects, besides an unique HTML id (and `assigns`),
  three arguments which correspond to the `data`, `options` and `type` fields
  that Chart.js uses, respectively.

  `type` should be a string. `data` and `options` can be any JSON that Chart.js expects.
  (See documentation at https://www.chartjs.org/docs/latest/getting-started/)

  LiveView can alter what data or options are used at any time,
  and these changes will be propagated.
  If only the info contained in the dataset(s) is altered, this will animate as 'new data'
  being added to the existing graph, rather than replacing the whole graph.
  """
  def chart(id, type, data, options, assigns) when is_binary(type) do
    ~L"""
    <div
      id="<%= id %>"
      phx-update="ignore"
      phx-hook="Chart"
      data-chart-type="<%= type %>"
      data-chart-data="<%= Jason.encode!(data) %>"
      data-chart-options="<%= Jason.encode!(options) %>"
    >
    </div>
    """
  end

end
