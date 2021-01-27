defmodule Vemosla.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias Vemosla.Accounts.User
  alias Vemosla.Timeline.{Comment, Reaction}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :description, :string
    field :movie_id, :integer
    field :visibility, Ecto.Enum, values: ~w(public private)a, default: :public
    belongs_to :user, User
    has_many :reactions, Reaction, on_delete: :delete_all
    has_many :comments, Comment, on_delete: :delete_all

    timestamps()
  end

  @required_fields ~w( movie_id description visibility )a
  @optional_fields ~w( user_id )a

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_assoc(:reactions)
    |> validate_required(@required_fields)
  end

  def list_my_timeline(query, friends_query, blocked_query, blockee_query, user_id) do
    from(
      p in query,
      where:
        p.user_id == ^user_id or
          (p.visibility == ^:public and
             p.user_id not in subquery(blocked_query) and
             p.user_id not in subquery(blockee_query)) or
          p.user_id in subquery(friends_query),
      order_by: [desc: p.updated_at]
    )
  end
end
