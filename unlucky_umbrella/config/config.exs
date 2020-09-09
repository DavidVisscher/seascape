# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config



config :unlucky_web,
  generators: [context_app: :unlucky]

# Configures the endpoint
config :unlucky_web, UnluckyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "rqMg4l62K9hB29qaR6fKdLvTSj4aKLZRWX5x4oMQiJ7F4vpLj6IJbgV3r6ni7cnl",
  render_errors: [view: UnluckyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Unlucky.PubSub,
  live_view: [signing_salt: "LeQUs3i7"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
