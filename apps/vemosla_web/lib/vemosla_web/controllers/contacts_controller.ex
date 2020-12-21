defmodule VemoslaWeb.ContactsController do
  use VemoslaWeb, :controller

  alias Vemosla.Accounts
  alias Vemosla.Contacts
  alias Vemosla.Contacts.Relation

  def new(conn, %{"id" => id}) do
    changeset = Contacts.change_relation(%Relation{})
    friend = Accounts.get_user!(id)
    render conn, "new.html",
           action: Routes.contacts_path(conn, :create),
           changeset: changeset,
           friend: friend
  end
  def new(conn, _params) do
    changeset = Contacts.change_relation(%Relation{})
    render conn, "new.html",
           action: Routes.contacts_path(conn, :create),
           changeset: changeset,
           friend: nil
  end

  def create(conn, %{"relation" => %{"friend_id" => _} = params}) do
    user = conn.assigns.current_user
    url = Routes.profile_path(conn, :show, user.id)
    friend = Accounts.get_user!(params["friend_id"])
    params =
      params
      |> Map.put("user_id", user.id)
      |> Map.put("friend_email", friend.email)
    case Contacts.invite(params, url) do
      {:ok, _relation} ->
        conn
        |> put_flash(:info, "Invitation sent.")
        |> redirect(to: "/")

      {:error, :send_email, _error, %{create_invitation: relation}} ->
        changeset = Contacts.change_relation(relation)
        friend = Accounts.get_user!(params["friend_id"])
        render(conn, "new.html",
               action: Routes.contacts_path(conn, :create),
               changeset: changeset,
               friend: friend)

      {:error, :create_invitation, %Ecto.Changeset{} = changeset, _} ->
        friend = Accounts.get_user!(params["friend_id"])
        render(conn, "new.html",
               action: Routes.contacts_path(conn, :create),
               changeset: changeset,
               friend: friend)
    end
  end
  def create(conn, %{"relation" => params}) do
    user = conn.assigns.current_user
    url = Routes.profile_path(conn, :show, user.id)
    params = Map.put(params, "user_id", user.id)
    case Contacts.invite(params, url) do
      {:ok, _relation} ->
        conn
        |> put_flash(:info, "Invitation sent.")
        |> redirect(to: "/")

      {:error, :send_email, _error, %{create_invitation: relation}} ->
        changeset = Contacts.change_relation(relation)
        render(conn, "new.html",
               action: Routes.contacts_path(conn, :create),
               changeset: changeset,
               friend: nil)

      {:error, :create_invitation, %Ecto.Changeset{} = changeset, _} ->
        render(conn, "new.html",
               action: Routes.contacts_path(conn, :create),
               changeset: changeset,
               friend: nil)
    end
  end

  def accept(conn, %{"id" => id}) do
    friend = conn.assigns.current_user
    user = Accounts.get_user!(id)
    Contacts.accept_invitation(user, friend)

    conn
    |> put_flash(:info, "Accepted invitation.")
    |> redirect(to: "/")
  end

  def block(conn, %{"id" => id}) do
    friend = conn.assigns.current_user
    user = Accounts.get_user!(id)
    Contacts.block_user(user, friend)

    conn
    |> put_flash(:info, "Blocked user.")
    |> redirect(to: "/")
  end

  def index(conn, _params) do
    user = conn.assigns.current_user
    received = Contacts.list_received_invitations(user.id)
    blocked = Contacts.list_blocked_users(user.id)
    sent =
      Contacts.list_sent_invitations(user.id)
      |> Enum.group_by(& &1.kind)
    render conn, "index.html", received: received, sent: sent, blocked: blocked
  end
end
