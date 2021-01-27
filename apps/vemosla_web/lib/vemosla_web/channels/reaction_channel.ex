defmodule VemoslaWeb.ReactionChannel do
  use VemoslaWeb, :channel
  require Logger
  alias Vemosla.Timeline

  @impl true
  def join("topic:reactions", payload, socket) do
    {:ok, assign(socket, :post_ids, payload["post_ids"])}
  end

  @impl true
  def handle_in("reaction", %{"post_id" => post_id} = payload, socket) do
    Logger.debug("params: #{inspect(payload)}")
    if post_id in socket.assigns.post_ids do
      user = socket.assigns.current_user
      watched = payload["watched"]

      if reaction = Timeline.get_reaction_by_post_and_user(post_id, user.id) do
        Logger.debug("reaction: #{inspect(reaction.reaction)} payload[\"reaction\"]: #{inspect(payload["reaction"])}")
        if reaction.reaction != payload["reaction"] or reaction.watched != watched do
          Timeline.update_reaction(reaction, watched, payload["reaction"])
          broadcast socket, "update_reactions", Timeline.all_reactions_by_post(post_id)
        end
      else
        Timeline.create_reaction(user.id, post_id, watched, payload["reaction"])
        broadcast socket, "update_reactions", Timeline.all_reactions_by_post(post_id)
      end
    end
    {:noreply, socket}
  end
end
