defmodule Vemosla.Contacts.Relation do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias Vemosla.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "relations" do
    field :kind, :string
    field :friend_email, :string
    belongs_to :user, User
    belongs_to :friend, User

    field :body_msg, :string, virtual: true, default: ""

    timestamps()
  end

  @required_fields [:kind, :friend_email, :user_id]
  @optional_fields [:friend_id, :body_msg]

  @doc false
  def changeset(relation, attrs) do
    relation
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:friend_email, :user_id])
  end

  def user_id_query(query, id) do
    from(r in query, where: r.user_id == ^id)
  end

  def friend_id_query(query, id) do
    from(r in query, where: r.friend_id == ^id)
  end

  def kind_query(query, kind) do
    from(r in query, where: r.kind == ^kind)
  end

  def select_friend_ids(query) do
    from(r in query, select: r.friend_id)
  end
end
