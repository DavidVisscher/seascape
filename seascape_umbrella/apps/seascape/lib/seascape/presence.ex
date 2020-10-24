defmodule Seascape.Presence do
  use Phoenix.Presence, otp_app: :seascape, pubsub_server: Seascape.PubSub
end
