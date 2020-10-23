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

# Configures the Web endpoint
config :seascape_web, SeascapeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FoY3bOfyhH70G3mISyy+iqavEDYBHN6uV+iNuj0Z3FhsEX+2MsJ5oDUdwki+cWAj",
  render_errors: [view: SeascapeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Seascape.PubSub,
  live_view: [signing_salt: "1ZK2yiDJ"]

# Configures the Ingest endpoint
config :seascape_ingest, SeascapeIngest.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ruYHpGSq6/Wlyu7shzNRegV0GpdFU0KpM2FWq3rgHg2bW0MzY5kjDCeDXzNW3aNr",
  render_errors: [view: SeascapeIngest.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Seascape.PubSub
  # live_view: [signing_salt: "SupM5BFi"]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elastic,
  index_prefix: "seascape"

# Distributed persistent store/cache:
config :mnesia, dir: to_charlist(System.get_env("MNESIA_DIR", "/tmp/mnesia/"))

# User management
config :seascape_web, :pow,
  user: Seascape.Users.User,
  users_context: Seascape.Users.PowContext,
  web_module: SeascapeWeb,
  cache_store_backend: Pow.Store.Backend.MnesiaCache

config :seascape_ingest, SeascapeIngest.Endpoint,
  scheme: :http,
  port: 4001


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
