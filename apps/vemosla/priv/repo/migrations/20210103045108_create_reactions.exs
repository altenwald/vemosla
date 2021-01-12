defmodule Vemosla.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :watched, :boolean, default: false, null: false
      add :reaction, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :post_id, references(:posts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:reactions, [:user_id])
    create index(:reactions, [:post_id])
  end
end
