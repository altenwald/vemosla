defmodule Vemosla.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset
  alias Vemosla.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "profiles" do
    field :city, :string
    field :country, :string
    field :name, :string
    field :photo, :string
    belongs_to :user, User

    timestamps()
  end

  @required_fields ~w(name country)a
  @optional_fields ~w(user_id photo city)a

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_format(:photo, ~r/\.(jpg|png)$/, message: "photo should be PNG or JPEG format")
  end
end
