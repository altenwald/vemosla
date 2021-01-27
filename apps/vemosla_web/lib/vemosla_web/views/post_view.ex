defmodule VemoslaWeb.PostView do
  use VemoslaWeb, :view

  defp watched?(reactions, user_id) do
    Enum.find(reactions, &(&1.user_id == user_id)).watched
  end

  defp reacted(reactions, user_id) do
    Enum.find(reactions, &(&1.user_id == user_id)).reaction
  end

  defp reactions(:watched) do
    Vemosla.Timeline.Reaction.reactions(true)
  end

  defp reactions(:non_watched) do
    Vemosla.Timeline.Reaction.reactions(false)
  end

  defp render_reactions(kind, post, render) do
    tags = reactions(kind)
    watched? = kind == :watched

    reactions =
      post.reactions
      |> Enum.filter(&(&1.watched == watched?))
      |> Enum.group_by(& &1.reaction)

    for tag <- tags do
      val = String.replace(tag, "_", " ")
      len = length(reactions[tag] || [])
      render.(tag, val, len)
    end
  end
end
