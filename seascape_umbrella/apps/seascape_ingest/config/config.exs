# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :seascape_ingest, SeascapeIngestWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ruYHpGSq6/Wlyu7shzNRegV0GpdFU0KpM2FWq3rgHg2bW0MzY5kjDCeDXzNW3aNr",
  render_errors: [view: SeascapeIngestWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: SeascapeIngest.PubSub,
  live_view: [signing_salt: "SupM5BFi"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
