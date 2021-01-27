defmodule VemoslaWeb.PostController do
  use VemoslaWeb, :controller

  alias Vemosla.Timeline

  def timeline(conn, _params) do
    user = conn.assigns.current_user
    npos = 1
    lang = "es"
    posts = Timeline.list_my_posts(user.id, npos, lang)
    render(conn, "timeline.html", posts: posts)
  end

  def new(conn, _params) do
    post = Timeline.new_post()
    changeset = Timeline.change_post(post)
    render(conn, "new.html", changeset: changeset)
  end

  defp reactions(%{"reactions" => %{"0" => %{"watched" => "true"}}} = params, user) do
    params
    |> put_in(
      ["reactions", "0", "reaction"],
      params["reactions"]["0"]["reaction_watched"]
    )
    |> put_in(["reactions", "0", "user_id"], user.id)
  end

  defp reactions(%{"reactions" => %{"0" => %{"watched" => "false"}}} = params, user) do
    params
    |> put_in(
      ["reactions", "0", "reaction"],
      params["reactions"]["0"]["reaction_non_watched"]
    )
    |> put_in(["reactions", "0", "user_id"], user.id)
  end

  def create(conn, %{"post" => post_params}) do
    user = conn.assigns.current_user

    post_params
    |> Map.put("user_id", user.id)
    |> reactions(user)
    |> Timeline.create_post()
    |> case do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: Routes.post_path(conn, :timeline))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    post = Timeline.get_post!(id)

    if post.user_id == user.id do
      {:ok, _post} = Timeline.delete_post(post)

      conn
      |> put_flash(:info, "Publicación eliminada.")
      |> redirect(to: Routes.post_path(conn, :timeline))
    else
      conn
      |> put_flash(:error, "No puedes borrar una publicación que no es tuya.")
      |> redirect(to: Routes.post_path(conn, :timeline))
    end
  end
end
