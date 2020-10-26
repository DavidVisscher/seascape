import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :seascape_web, SeascapeWeb.Endpoint,
  http: [port: 4002],
  server: false

config :seascape_ingest, SeascapeIngestWeb.Endpoint,
  http: [port: 4003],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
