defmodule ExToolkit.TestRepo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:title, :string)
      timestamps()
    end
  end
end
