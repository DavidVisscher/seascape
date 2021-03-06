# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :seascape_web, SeascapeWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]],
  ],
  server: true,
  secret_key_base: secret_key_base,
  url: [host: System.get_env("SEASCAPE_WEB_HOST", "seascape.example")]

config :seascape_ingest, SeascapeIngest.Endpoint,
  http: [
    port: String.to_integer(System.get_env("INGEST_PORT") || "4001"),
    transport_options: [socket_opts: [:inet6]]
  ],
  server: true,
  secret_key_base: secret_key_base

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :seascape_web, SeascapeWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.

config :elastic,
  base_url: System.get_env("ELASTICSEARCH_DB_URL")
#  basic_auth: {System.get_env("ELASTICSEARCH_USER"), System.get_env("ELASTICSEARCH_PASSWORD")},

# Override Mnesia persistency directory to be in current working directory
# rather than in a static location as on production
config :mnesia, dir: to_charlist(System.get_env("MNESIA_DIR", "/tmp/mnesia/"))

other_elixir_cluster_nodes =
  System.get_env("OTHER_ELIXIR_CLUSTER_NODES", "")
  |> String.split(",")
  |> Enum.reject(&(&1==""))
  |> Enum.map(&String.to_atom/1)

IO.puts("Connecting to the following elixir cluster nodes at startup:")
IO.inspect(other_elixir_cluster_nodes)

# Allow Elixir-nodes to discover each-other
config :libcluster,
  topologies: [
    web_ingest_cluster: [
      strategy: Elixir.Cluster.Strategy.Epmd,
      config: [
        hosts: other_elixir_cluster_nodes]]]
