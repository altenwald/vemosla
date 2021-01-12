defmodule Vemosla.Timeline.Reaction do
  use Ecto.Schema
  import Ecto.Changeset
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
  @optional_fields ~w[ user_id reaction_id ]a

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
