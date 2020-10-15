defmodule SeascapeIngest.IngestPlug do
  import Plug.Conn
  import Solution

  @moduledoc """

  """

  def init(options) do
    options
  end

  def call(conn, _opts) do
    conn = put_resp_content_type(conn, "application/json")

    swith ok() <- authenticate_api_key(conn.params),
          ok() <- store_cluster_info(conn.params)
      do
        send_success_response(conn)
      else
        error(problem) ->
          send_error_response(conn, problem)
    end
  end

  def authenticate_api_key(%{"api_key" => api_key}) do
    scase Seascape.Clusters.get_cluster_by_api_key(api_key) do
      ok(cluster) ->
        {:ok, cluster}
      error() ->
        {:error, "Unknown API key"}
    end
  end
  def authenticate_api_key(_params) do
    {:error, "Missing field: `api_key`"}
  end

  def store_cluster_info(params) do
    # TODO request parsing logic here.
    :ok
  end

  defp send_success_response(conn) do
    conn
    |> send_resp(200, success_json())
  end

  defp success_json do
    %{status: :ok}
    |> Jason.encode!
  end

  defp send_error_response(conn, problem) do
    conn
    |> send_resp(400, error_json(problem))
  end

  defp error_json(problem) do
    %{status: :error, message: problem}
    |> Jason.encode!
  end
end
