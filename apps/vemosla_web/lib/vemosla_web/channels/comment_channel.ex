defmodule VemoslaWeb.CommentChannel do
  use VemoslaWeb, :channel
  require Logger
  alias Vemosla.Timeline
  alias VemoslaWeb.Router.Helpers, as: Routes

  @impl true
  def join("topic:comments", payload, socket) do
    {:ok, assign(socket, :post_ids, payload["post_ids"])}
  end

  @impl true
  def handle_in("comment", %{"post_id" => post_id} = payload, socket) do
    Logger.debug("params: #{inspect(payload)}")
    user = socket.assigns.current_user
    case Timeline.create_comment(user.id, post_id, payload["text"]) do
      {:ok, comment} ->
        broadcast socket, "comment", %{
          "photo" => user.profile.photo,
          "inserted_at" => NaiveDateTime.utc_now(),
          "user_name" => user.profile.name,
          "user_profile_url" => Routes.profile_url(socket, :show, user.id),
          "post_id" => post_id,
          "comment" => payload["text"]
        }
        {:reply, {:ok, comment.id}, socket}

      {:error, _changeset} ->
        {:reply, :error, socket}
    end
  end

  intercept ["comment"]

  @impl true
  def handle_out("comment", msg, socket) do
    if msg["post_id"] in socket.assigns.post_ids do
      push(socket, "comment", msg)
    end
    {:noreply, socket}
  end
end
