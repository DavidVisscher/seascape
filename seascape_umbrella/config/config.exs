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



config :seascape_web,
  generators: [context_app: :seascape]

# Configures the endpoint
config :seascape_web, SeascapeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FoY3bOfyhH70G3mISyy+iqavEDYBHN6uV+iNuj0Z3FhsEX+2MsJ5oDUdwki+cWAj",
  render_errors: [view: SeascapeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Seascape.PubSub,
  live_view: [signing_salt: "1ZK2yiDJ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# User management
# config :seascape_web, :pow,
#   user: Seascape.Users.User,
#   repo: Seascape.Repo
config :seascape_web, :pow,
  user: Seascape.Users.User,
  users_context: Seascape.Users.PowContext

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
