defmodule VemoslaWeb.ProfileController do
  use VemoslaWeb, :controller

  alias Vemosla.{Accounts, Contacts}

  def show(conn, %{"id" => user_id}) do
    friend = conn.assigns.current_user
    if friend.id == user_id do
      show(conn, %{})
    else
      contact = Contacts.get_relation_by_email_and_user_id(friend.email, user_id)
      user = Accounts.get_user!(user_id)
      render(conn, "show.html", profile: user.profile, contact: contact)
    end
  end
  def show(conn, _params) do
    profile = conn.assigns.current_user.profile
    render(conn, "show.html", profile: profile)
  end

  def edit(conn, _params) do
    profile = conn.assigns.current_user.profile
    changeset = Accounts.change_profile(profile)
    render(conn, "edit.html", profile: profile, changeset: changeset)
  end

  def update(conn, %{"profile" => profile_params}) do
    user = conn.assigns.current_user
    profile = user.profile
    profile_params = Map.put(profile_params, "user_id", user.id)

    case Accounts.update_profile(profile, profile_params) do
      {:ok, _profile} ->
        conn
        |> put_flash(:info, "Profile updated successfully.")
        |> redirect(to: Routes.profile_path(conn, :show))

      {:error, :copy_file, _error, %{update_profile: profile}} ->
        changeset = Accounts.change_profile(profile)
        render(conn, "edit.html", profile: profile, changeset: changeset)

      {:error, :update_profile, %Ecto.Changeset{} = changeset, _} ->
        render(conn, "edit.html", profile: profile, changeset: changeset)
    end
  end
end
