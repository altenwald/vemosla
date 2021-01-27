defmodule VemoslaWeb.PageController do
  use VemoslaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
