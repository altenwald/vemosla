defmodule Vemosla.Features.Feature do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Vemosla.Accounts.User
  alias Vemosla.Features.Feature

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "features" do
    field :description, :string
    field :title, :string
    field :votes, :integer, default: 0
    belongs_to :user, User

    timestamps()
  end

  @required_fields ~w[ title user_id ]a
  @optional_fields ~w[ description votes ]a

  @doc false
  def changeset(feature, attrs) do
    feature
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:title, min: 5, message: "debe tener un mínimo de 5 caracteres")
  end

  def get_by_id(id) do
    from(f in Feature, where: f.id == ^id)
  end
end
