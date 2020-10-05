defmodule SeascapeWeb.State.Ephemeral do
  use CapturePipe

  defstruct [current_page: []]

  def new do
    {:ok, %__MODULE__{}}
  end

  def handle_event(state, {["changed_page"], %{"spa_path" => new_page}}) do
    state.current_page
    |> put_in(new_page)
  end

  # def handle_event(state, {["change_page"], %{"spa_path" => new_page}}) do
  #   effect = fn socket ->
  #     live_redirect(new_page)
  #   end
  #   {state, []}
  # end
end
