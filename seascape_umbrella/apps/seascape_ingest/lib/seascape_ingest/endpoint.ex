defmodule SeascapeIngest.Endpoint do
  use Plug.Router

  require Logger

  plug(Plug.Logger, log: :debug)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  post("/ingest", to: SeascapeIngest.IngestPlug)

  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, Jason.encode!(%{status: "error", message: "not found"}))
  end

  # defp config, do: Application.fetch_env(:seascape_ingest, __MODULE__)
end
