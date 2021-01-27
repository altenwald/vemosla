defmodule Vemosla.Timeline.Reaction do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias Vemosla.Accounts.User
  alias Vemosla.Timeline.Post

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "reactions" do
    field :reaction, :string
    field :watched, :boolean, default: false
    belongs_to :user, User
    belongs_to :post, Post

    timestamps()
  end

  @required_fields ~w[ watched reaction ]a
  @optional_fields ~w[ user_id ]a

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def watched(query, user_id) do
    from(
      r in query,
      where: r.user_id == ^user_id and r.watched
    )
  end

  def want_watch(query, user_id) do
    from(
      r in query,
      where: r.user_id == ^user_id and not r.watched and r.reaction == "hype"
    )
  end
end
