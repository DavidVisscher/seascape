defmodule SeascapeIngest.Router do
  use SeascapeIngestWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SeascapeIngest do
    pipe_through :api
  end
end
