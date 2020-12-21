defmodule Vemosla.Repo.Migrations.CreateRelations do
  use Ecto.Migration

  def change do
    create table(:relations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :kind, :string
      add :friend_email, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :friend_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:relations, [:user_id])
    create index(:relations, [:friend_id])

    create unique_index(:relations, [:friend_email, :user_id])
  end
end
