defmodule VemoslaWeb.Api.Recaptcha do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://www.google.com/recaptcha/api"
  plug Tesla.Middleware.Headers, [{"content-type", "application/json"}]
  plug Tesla.Middleware.JSON

  def verify(token) do
    secret = Application.get_env(:vemosla_web, :secret_key)
    opts = %{"secret" => secret, "reponse" => token}
    case post("/siteverify", %{}, query: opts) do
      {:ok, %{body: body}} -> {:ok, body}
      {:error, _} = error -> error
    end
  end
end
