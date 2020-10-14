defmodule SeascapeIngest.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(response()))
  end

  defp response do
    %{status: "ok"}
  end
end
