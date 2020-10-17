defmodule SeascapeWeb.State.Persistent.Cluster do
  defstruct [:name, :id, :api_key]

  def handle_event(state, {event, params}) do
    # For now do nothing
    case {event, params} do
      _ ->
        {state, []}
    end
  end
end
