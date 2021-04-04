defmodule VemoslaWeb.CommentChannel do
  use VemoslaWeb, :channel
  require Logger
  alias Vemosla.{Contacts, Timeline}
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
          "user_id" => user.id,
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
      push(socket, "comment", Map.delete(msg, "user_id"))
    end
    user = socket.assigns.current_user
    notify(socket, msg, user)
    {:noreply, socket}
  end

  defp notify(_socket, %{"user_id" => user_id}, %_{id: user_id}), do: :ok

  defp notify(socket, %{"user_id" => friend_id} = msg, user) do
    msg =
      msg
      |> Map.delete("user_id")
      |> Map.put("icon", Routes.static_path(socket, "/images/favicon/android-icon-192x192.png"))

    case Contacts.can_talk_together?(friend_id, user.id) do
      "blocked" ->
        Logger.debug("[#{user.id}] usuario bloqueado user_id=#{friend_id}")
        :ok

      "accepted" ->
        Logger.debug("[#{user.id}] envía notificación de user_id#{friend_id}")
        push(socket, "notification", msg)

      _ ->
        post = Timeline.get_post!(msg["post_id"])
        if post.visibility == :public do
          Logger.debug("[#{user.id}] envía notificación de user_id=#{friend_id}")
          push(socket, "notification", msg)
        else
          Logger.debug("[#{user.id} no recibe notificación de post privado (post_id=#{msg["post_id"]}")
        end
    end
  end
end
