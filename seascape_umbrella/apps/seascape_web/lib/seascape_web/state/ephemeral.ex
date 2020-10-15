defmodule SeascapeWeb.State.Ephemeral do
  use CapturePipe

  defstruct [current_page: [], repository_ok?: false]

  def new do
    Seascape.Repository.subscribe_to_cluster_status()
    {:ok, %__MODULE__{repository_ok?: Seascape.Repository.cluster_ok?() }}
  end

  def handle_event(state, event) do
    case event do
      {["changed_page"], %{"spa_path" => new_page}} ->
        state.current_page
        |> put_in(new_page)
      {["repository", "connected"], status} ->
        state.repository_ok?
        |> put_in(status)
    end
  end
end
