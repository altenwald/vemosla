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

  defp reactions(%{"reactions" => %{"0" => %{"watched" => "true"}}} = params) do
    put_in(
      params["reactions"]["0"]["reaction"],
      params["reactions"]["0"]["reaction_watched"]
    )
  end
  defp reactions(%{"reactions" => %{"0" => %{"watched" => "false"}}} = params) do
    put_in(
      params["reactions"]["0"]["reaction"],
      params["reactions"]["0"]["reaction_non_watched"]
    )
  end

  def create(conn, %{"post" => post_params}) do
    post_params
    |> reactions()
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
    post = Timeline.get_post!(id)
    {:ok, _post} = Timeline.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: Routes.post_path(conn, :index))
  end
end
