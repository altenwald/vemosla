defmodule VemoslaWeb.Api.Freegeoip do
  use Tesla
  require Logger

  plug Tesla.Middleware.BaseUrl, "http://api.ipstack.com"
  plug Tesla.Middleware.Headers, [{"content-type", "application/json"}]
  plug Tesla.Middleware.JSON

  defp api_key do
    Application.get_env(:vemosla_web, :freegeoip_api_key)
  end

  def geoip(ip) when is_tuple(ip) do
    ip
    |> :inet.ntoa()
    |> to_string()
    |> geoip()
  end

  def geoip(ip) when is_binary(ip) do
    case lookup(ip) do
      {:ok, %{body: body}} ->
        {:ok,
         %{
           "country" => body["country_code"] || "ES",
           "city" => body["city"] || ""
         }}

      error ->
        Logger.error("not found IP #{ip}: #{inspect(error)}")
        error
    end
  end

  def lookup(ip) when is_binary(ip) do
    get("/#{ip}", query: %{"access_key" => api_key()})
  end
end
