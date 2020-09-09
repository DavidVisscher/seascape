defmodule UnluckyWeb.PageController do
  use UnluckyWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
