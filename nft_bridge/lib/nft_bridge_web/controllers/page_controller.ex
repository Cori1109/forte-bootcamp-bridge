defmodule NftBridgeWeb.PageController do
  use NftBridgeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
