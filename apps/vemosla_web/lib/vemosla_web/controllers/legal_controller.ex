defmodule VemoslaWeb.LegalController do
  use VemoslaWeb, :controller

  plug :put_layout, "legal.html"

  def terminos_de_servicio(conn, _params) do
    render(conn, "terminos_de_servicio.html")
  end

  def terms_of_service(conn, _params) do
    render(conn, "terms_of_service.html")
  end
end
