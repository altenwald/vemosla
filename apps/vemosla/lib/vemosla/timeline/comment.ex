defmodule Vemosla.Timeline.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias Vemosla.Accounts.User
  alias Vemosla.Timeline.Post

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comments" do
    field :comment, :string
    belongs_to :user, User
    belongs_to :post, Post

    timestamps()
  end

  @required_fields ~w[ comment user_id post_id  ]a
  @optional_fields ~w[ ]a

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def by_post_id(query, post_id) do
    from(c in query, where: c.post_id == ^post_id)
  end
end
