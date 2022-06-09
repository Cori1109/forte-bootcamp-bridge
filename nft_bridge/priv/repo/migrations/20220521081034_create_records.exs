defmodule NftBridge.Repo.Migrations.CreateRecords do
  use Ecto.Migration

  def change do
    create table(:records) do
      add :id, :uuid
      add :created_at, :utc_datetime
      add :updated_at, :utc_datetime
      add :owner_address, :string
      add :recipient_address, :string
      add :token_id, :string
      add :status, :string

      timestamps()
    end

    create unique_index(:records, [:id])
  end
end
