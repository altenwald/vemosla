defmodule VemoslaWeb.Locale do
  import Plug.Conn
  require Logger

  def init(_opts), do: nil

  def call(conn, _opts) do
    case conn.params["locale"] || get_session(conn, :locale) || get_lang() do
      nil ->
        Logger.error("ignoring locale!!!")
        conn

      locale ->
        Gettext.put_locale(VemoslaWeb.Gettext, locale)
        Logger.debug("setting locale as '#{locale}'")

        conn
        |> put_session(:locale, locale)
        |> assign(:locale, locale)
    end
  end

  defp get_lang() do
    Gettext.get_locale()
  end
end
