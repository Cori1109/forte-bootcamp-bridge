defmodule NftBridge.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :owner_address, :string
      add :receipt_address, :string
      add :status, :string
      add :token_id, :string

      timestamps()
    end

  end
end
