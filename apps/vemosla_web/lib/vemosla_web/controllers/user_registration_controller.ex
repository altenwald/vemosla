defmodule VemoslaWeb.UserRegistrationController do
  use VemoslaWeb, :controller
  require Logger

  alias Vemosla.Accounts
  alias Vemosla.Accounts.User
  alias VemoslaWeb.UserAuth
  alias VemoslaWeb.Api.Freegeoip

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    {:ok, loc} = Freegeoip.geoip(conn.remote_ip)
    profile = Map.merge(user_params["profile"], loc)
    user_params = %{user_params | "profile" => profile}

    if GoogleRecaptcha.valid?(user_params["recaptcha"]) do
      case Accounts.register_user(user_params) do
        {:ok, user} ->
          {:ok, _} =
            Accounts.deliver_user_confirmation_instructions(
              user,
              &Routes.user_confirmation_url(conn, :confirm, &1)
            )

          conn
          |> put_flash(:info, "User created successfully.")
          |> UserAuth.log_in_user(user)

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    else
      changeset = Accounts.change_user_registration(%User{})

      conn
      |> put_flash(:error, "Eres un robot!!!")
      |> render("new.html", changeset: changeset)
    end
  end
end
