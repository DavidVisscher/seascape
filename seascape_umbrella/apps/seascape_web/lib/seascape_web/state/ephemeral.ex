defmodule SeascapeWeb.State.Ephemeral do
  use CapturePipe

  defstruct [current_page: []]

  def new do
    {:ok, %__MODULE__{}}
  end

  def handle_event(state, {["change_page"], %{"page" => new_page}}) do
    new_page = String.split(new_page)

    state.current_page
    |> put_in(new_page)
  end
end
