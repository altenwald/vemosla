defmodule Vemosla.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :movie_id, :integer
      add :description, :text
      add :visibility, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:posts, [:user_id])
    create index(:posts, [:movie_id])
  end
end
