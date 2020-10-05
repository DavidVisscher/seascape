defmodule SeascapeWeb.Credentials do
  @moduledoc """
  Authentication helper functions.

  Based on this discussion: https://github.com/danschultzer/pow/issues/271
  """

  alias Phoenix.LiveView.Socket
  alias Pow.Store.CredentialsCache

  @doc """
  Retrieves the currently-logged-in user from the Pow credentials cache.
  """
  @spec get_user(
    socket :: Socket.t(),
    session :: map(),
    config :: keyword()
  ) :: %Seascape.Users.User{} | nil

  def get_user(socket, session, config \\ [otp_app: :seascape_web])

  def get_user(socket, %{"seascape_web_auth" => signed_token}, config) do
    conn = struct!(Plug.Conn, secret_key_base: socket.endpoint.config(:secret_key_base))
    salt = Atom.to_string(Pow.Plug.Session)

    with {:ok, token} <- Pow.Plug.verify_token(conn, salt, signed_token, config),
         # Replaced  `[backend: Pow.Store.Backend.EtsCache]` with `config`
         {user, _metadata} <- CredentialsCache.get(config, token) do
      user
    else
      _any -> nil
    end
  end

  def get_user(_, _, _), do: nil
end
