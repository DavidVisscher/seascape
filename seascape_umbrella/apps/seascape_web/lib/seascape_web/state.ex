defmodule SeascapeWeb.State do
  defstruct [:ephemeral, :persistent]

  alias __MODULE__.{Ephemeral, Persistent}
  alias SeascapeWeb.Effect
  require Effect

  def new() do
    with {:ok, ephemeral} <- Ephemeral.new() do
      {:ok, %__MODULE__{ephemeral: ephemeral, persistent: nil}}
    end
  end

  def new(current_user) do
    with {:ok, ephemeral} <- Ephemeral.new(),
         {:ok, persistent} <- Persistent.new(current_user) do
      {:ok, %__MODULE__{ephemeral: ephemeral, persistent: persistent}}
    end
  end

  def handle_event(state, {event, params}) do
    case event do
      ["ephemeral" | rest] ->
        Effect.update_in(state.ephemeral, &Ephemeral.handle_event(&1, {rest, params}))
      ["persistent" | rest] ->
        Effect.update_in(state.persistent, &Persistent.handle_event(&1, {rest, params}))
    end
  end
end
