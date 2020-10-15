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
      ok <- store_cluster_info(conn.params)
      do
        send_success_response(conn)
      else
        error(problem) ->
          send_error_response(conn, problem)
    end
  end

  def authenticate_api_key(params) do
    :ok
  end

  def store_cluster_info(params) do
    # {:error, "foo bar"}
    :ok
  end


  # def send_response(conn, ok_or_error) do
  #   conn = put_resp_content_type(conn, "application/json")

  #   scase ok_or_error do
  #     ok() ->
  #       send_success_response(conn)
  #     error(problem) ->
  #       send_error_response(conn, problem)
  #   end
  # end

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
