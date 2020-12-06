defmodule Vemosla.Repo do
  use Ecto.Repo,
    otp_app: :vemosla,
    adapter: Ecto.Adapters.Postgres
end
